import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/entities/finance_date.dart';
import '../domain/entities/finance_enums.dart';
import '../domain/entities/finance_inputs.dart';
import 'finance_providers.dart';

/// Период отчёта: этот и прошлый месяц, квартал или свой (FP-512:
/// «произвольный период, не только календарный месяц»).
enum FinanceReportPeriodKind { thisMonth, lastMonth, quarter, custom }

@immutable
class FinanceReportPeriodChoice {
  const FinanceReportPeriodChoice(this.kind, {this.from, this.to});

  final FinanceReportPeriodKind kind;

  /// Границы своего периода. Пока не выбраны — с начала месяца по сегодня.
  final DateTime? from;
  final DateTime? to;

  FinancePeriod resolve(DateTime today) {
    final month = monthStart(today);
    switch (kind) {
      case FinanceReportPeriodKind.thisMonth:
        return FinancePeriod.month(month);
      case FinanceReportPeriodKind.lastMonth:
        return FinancePeriod.month(addMonths(month, -1));
      case FinanceReportPeriodKind.quarter:
        final start = DateTime.utc(today.year, (today.month - 1) ~/ 3 * 3 + 1);
        return FinancePeriod(start, addDays(addMonths(start, 3), -1));
      case FinanceReportPeriodKind.custom:
        final start = from ?? month;
        final end = to ?? today;
        return start.isAfter(end)
            ? FinancePeriod(end, end)
            : FinancePeriod(start, end);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is FinanceReportPeriodChoice &&
      other.kind == kind &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(kind, from, to);
}

/// Выбор на вкладке «Отчёт»; живёт, пока открыт раздел.
final financeReportPeriodProvider =
    StateProvider.autoDispose<FinanceReportPeriodChoice>(
      (ref) =>
          const FinanceReportPeriodChoice(FinanceReportPeriodKind.thisMonth),
    );

final financeReportTypeProvider = StateProvider.autoDispose<FinanceReportType>(
  (ref) => FinanceReportType.full,
);

/// PDF, сохранённый на телефоне и готовый к отправке.
@immutable
class FinanceReportDocument {
  const FinanceReportDocument({
    required this.path,
    required this.fileName,
    required this.sizeBytes,
    required this.request,
  });

  final String path;
  final String fileName;
  final int sizeBytes;
  final FinanceReportRequest request;
}

/// Папка для отчётов. В тестах подменяется временной.
final financeReportDirectoryProvider = Provider<Future<Directory> Function()>(
  (ref) => getTemporaryDirectory,
);

/// Системное «Поделиться»: WhatsApp бухгалтеру, почта, «Сохранить в Файлы».
/// [origin] — откуда на iPad выезжает окно. В тестах подменяется.
final financeShareFileProvider =
    Provider<Future<void> Function(FinanceReportDocument, Rect? origin)>(
      (ref) =>
          (document, origin) => SharePlus.instance.share(
            ShareParams(
              files: [
                XFile(
                  document.path,
                  mimeType: 'application/pdf',
                  name: document.fileName,
                ),
              ],
              title: document.fileName,
              sharePositionOrigin: origin,
            ),
          ),
    );

final financeReportFilesProvider = Provider<FinanceReportFiles>(
  (ref) => FinanceReportFiles(ref),
);

/// Забирает PDF у бэкенда и кладёт во временную папку: «Поделиться»
/// отправляет файлы, а не байты. Прежние отчёты удаляются.
class FinanceReportFiles {
  FinanceReportFiles(this._ref);

  final Ref _ref;

  Future<FinanceReportDocument> generate(
    FinanceReportRequest request, {
    required String fallbackName,
  }) async {
    final file = await _ref
        .read(financeRepositoryProvider)
        .getReportPdf(request);
    final base = await _ref.read(financeReportDirectoryProvider)();
    final folder = Directory('${base.path}${Platform.pathSeparator}finance');
    if (folder.existsSync()) folder.deleteSync(recursive: true);
    folder.createSync(recursive: true);

    final name = safeReportFileName(file.fileName ?? fallbackName);
    final target = File('${folder.path}${Platform.pathSeparator}$name');
    // Файл в килобайты; синхронная запись проще и надёжнее.
    target.writeAsBytesSync(file.bytes, flush: true);
    return FinanceReportDocument(
      path: target.path,
      fileName: name,
      sizeBytes: file.bytes.length,
      request: request,
    );
  }
}

/// Имя файла без символов, запрещённых в файловых системах, и с `.pdf`.
String safeReportFileName(String name) {
  var safe = name
      .replaceAll(RegExp(r'[\\/:*?"<>|«»\x00-\x1F]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  if (safe.isEmpty || safe == '.pdf') safe = 'report.pdf';
  if (!safe.toLowerCase().endsWith('.pdf')) safe = '$safe.pdf';
  return safe;
}

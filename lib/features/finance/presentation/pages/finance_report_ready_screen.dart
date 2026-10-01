import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_outlined_button.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_report.dart';
import '../widgets/finance_common.dart';
import '../widgets/finance_page.dart';
import '../widgets/finance_report_contents.dart';

/// «Отчёт готов» (FP-512): файл, что в нём, и «Отправить» — WhatsApp
/// бухгалтеру, почта или «Сохранить в Файлы» из системного меню.
///
/// Документ приходит из вкладки «Отчёт» в `extra`; по прямой ссылке его
/// нет — предлагаем сформировать заново.
class FinanceReportReadyScreen extends ConsumerWidget {
  const FinanceReportReadyScreen({super.key, this.document});

  final FinanceReportDocument? document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final document = this.document;
    if (document == null) {
      return FinancePage(
        title: l10n.financeReportReadyTitle,
        children: [
          FinanceMessageCard(title: l10n.financeReportMissing),
          AppOutlinedButton(
            text: l10n.financeReportMake,
            onPressed: () => context.go('/finance?tab=report'),
          ),
        ],
      );
    }

    return FinancePage(
      title: l10n.financeReportReadyTitle,
      spacing: 18,
      children: [
        _DocumentCard(document: document),
        FinanceReportContents(request: document.request),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Builder(
              builder: (buttonContext) => AppPrimaryButton(
                text: l10n.financeReportShare,
                onPressed: () => _share(buttonContext, ref, document),
              ),
            ),
            const SizedBox(height: 10),
            FinanceNote(l10n.financeReportShareHint),
          ],
        ),
      ],
    );
  }

  Future<void> _share(
    BuildContext context,
    WidgetRef ref,
    FinanceReportDocument document,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    // На iPad окно «Поделиться» выезжает от кнопки.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null || !box.hasSize
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    try {
      await ref.read(financeShareFileProvider)(document, origin);
    } catch (error) {
      showFinanceMessage(messenger, extractApiMessage(error));
    }
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document});

  final FinanceReportDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FinanceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const FinanceIconSquare(icon: 'document', color: AppColors.primary1),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    document.request.type.localizedLabel(l10n),
                    financeFileSize(context, document.sizeBytes),
                  ].join(' · '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.additional3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `184 КБ`, `1,2 МБ`.
String financeFileSize(BuildContext context, int bytes) {
  final l10n = context.l10n;
  final separator = Localizations.localeOf(context).languageCode == 'en'
      ? '.'
      : ',';
  if (bytes < 1024 * 1024) {
    final kb = (bytes / 1024).ceil();
    return l10n.financeFileSizeKb('${kb < 1 ? 1 : kb}');
  }
  final tenths = (bytes * 10 / (1024 * 1024)).round();
  return l10n.financeFileSizeMb('${tenths ~/ 10}$separator${tenths % 10}');
}

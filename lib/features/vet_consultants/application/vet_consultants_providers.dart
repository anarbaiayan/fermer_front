import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/datasources/vet_consultants_api.dart';
import '../data/models/vet_consultant_dto.dart';

/// Список доступных ветврачей.
final vetConsultantsProvider =
    FutureProvider.autoDispose<List<VetConsultantDto>>((ref) async {
      final api = ref.read(vetConsultantsApiProvider);
      return api.getConsultants();
    });

/// Фиксация перехода в WhatsApp. Это только аналитика для админа, поэтому
/// ошибка здесь не должна мешать пользователю открыть чат — вызывающий код
/// намеренно игнорирует исключение.
final registerConsultationClickProvider =
    Provider<Future<void> Function(int consultantId)>((ref) {
      return (consultantId) async {
        final api = ref.read(vetConsultantsApiProvider);
        await api.registerClick(consultantId);
      };
    });

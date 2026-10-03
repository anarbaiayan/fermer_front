import 'milking_time.dart';

/// Что делать с коровами, у которых на выбранную дату и время доения уже есть
/// контрольный замер.
enum ControlMilkingDuplicateAction {
  /// Оставить существующую запись, новую не создавать.
  keepExisting,

  /// Перезаписать существующую запись новым значением.
  update,
}

/// Одна строка контрольного надоя, готовая к отправке.
class ControlMilkingEntry {
  final int cattleId;
  final String cattleTagNumber;
  final double liters;

  const ControlMilkingEntry({
    required this.cattleId,
    required this.cattleTagNumber,
    required this.liters,
  });
}

/// Итог сохранения. Частичный успех — штатная ситуация: сеть может отвалиться
/// на середине списка из 100 животных, и экран должен показать, что именно
/// не сохранилось, не потеряв введённые данные.
class ControlMilkingSaveResult {
  final DateTime date;
  final MilkingTime milkingTime;
  final int savedCount;
  final int keptExistingCount;
  final double savedLiters;

  /// Коровы, по которым на сервере всё уже в порядке: запись создана,
  /// обновлена или сознательно оставлена прежней. Повторная отправка им
  /// не нужна.
  final Set<int> processedCattleIds;

  /// cattleId -> ошибка. Пустая карта означает полный успех.
  final Map<int, Object> failures;

  const ControlMilkingSaveResult({
    required this.date,
    required this.milkingTime,
    required this.savedCount,
    required this.keptExistingCount,
    required this.savedLiters,
    required this.processedCattleIds,
    required this.failures,
  });

  bool get hasFailures => failures.isNotEmpty;
}

/// Черновик контрольного надоя, общий для обоих шагов.
///
/// Живёт вне экранов, поэтому Back со второго шага на первый и обратно не
/// теряет ни выбор коров, ни уже введённые литры.
class ControlMilkingDraft {
  final DateTime date;
  final MilkingTime milkingTime;
  final Set<int> selectedIds;

  /// cattleId -> введённый пользователем текст.
  ///
  /// Хранится именно текст: отсутствие ключа (или пустая строка) значит
  /// "замер не вносили", а "0" — "корову подоили, она дала 0 л". Это разные
  /// состояния, и пустое значение никогда не превращается в ноль.
  final Map<int, String> values;

  const ControlMilkingDraft({
    required this.date,
    required this.milkingTime,
    required this.selectedIds,
    required this.values,
  });

  ControlMilkingDraft.initial()
    : date = DateTime.now(),
      milkingTime = MilkingTime.morning,
      selectedIds = const {},
      values = const {};

  bool get isEmpty => selectedIds.isEmpty && values.isEmpty;

  ControlMilkingDraft copyWith({
    DateTime? date,
    MilkingTime? milkingTime,
    Set<int>? selectedIds,
    Map<int, String>? values,
  }) {
    return ControlMilkingDraft(
      date: date ?? this.date,
      milkingTime: milkingTime ?? this.milkingTime,
      selectedIds: selectedIds ?? this.selectedIds,
      values: values ?? this.values,
    );
  }
}

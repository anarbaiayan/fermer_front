import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/control_milking_providers.dart';
import '../../domain/entities/control_milking.dart';
import '../../domain/entities/lactation_validation.dart';
import '../../domain/entities/milking_candidate.dart';
import '../../domain/entities/milking_time.dart';
import '../lactation_error_message.dart';
import '../widgets/control_milking_widgets.dart';

/// Высота строки списка. Фиксирована намеренно: по ней считается прокрутка к
/// следующему полю, и она же позволяет ListView не измерять 500 элементов.
const _rowExtent = 62.0;

/// Шаг 2 контрольного надоя — ввод литров по каждой выбранной корове.
///
/// Экран рассчитан на быстрый табличный ввод: компактные строки, цифровая
/// клавиатура и переход по "Next" к следующей корове.
class ControlMilkingValuesScreen extends ConsumerStatefulWidget {
  const ControlMilkingValuesScreen({super.key});

  @override
  ConsumerState<ControlMilkingValuesScreen> createState() =>
      _ControlMilkingValuesScreenState();
}

class _ControlMilkingValuesScreenState
    extends ConsumerState<ControlMilkingValuesScreen> {
  final _dmy = DateFormat('dd.MM.yyyy');

  final _controllers = <int, TextEditingController>{};
  final _focusNodes = <int, FocusNode>{};
  final _scrollController = ScrollController();

  /// Снимок "незаполненных" на момент включения фильтра.
  ///
  /// Список не пересобирается на каждый введённый символ — иначе строка
  /// исчезала бы прямо под пальцем и экран прыгал бы при вводе.
  Set<int>? _unfilledSnapshot;

  final _filled = ValueNotifier<int>(0);
  final _totalLiters = ValueNotifier<double>(0);
  final _unfilledCount = ValueNotifier<int>(0);

  Set<int> _invalidIds = {};
  bool _saving = false;

  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    // Значения из черновика: возврат со второго шага на первый и обратно не
    // должен терять введённое.
    final draft = ref.read(controlMilkingDraftProvider);
    for (final entry in draft.values.entries) {
      _controllerFor(entry.key).text = entry.value;
    }
    // Уход в фон — тоже повод зафиксировать введённое: 100 значений слишком
    // дорого вводить заново.
    _lifecycle = AppLifecycleListener(onInactive: _syncDraft);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    _scrollController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _filled.dispose();
    _totalLiters.dispose();
    _unfilledCount.dispose();
    super.dispose();
  }

  TextEditingController _controllerFor(int cattleId) {
    return _controllers.putIfAbsent(cattleId, () {
      final controller = TextEditingController();
      controller.addListener(_recompute);
      return controller;
    });
  }

  FocusNode _focusFor(int cattleId) {
    return _focusNodes.putIfAbsent(cattleId, FocusNode.new);
  }

  List<MilkingCandidate> _selectedCows() {
    final draft = ref.read(controlMilkingDraftProvider);
    final all = ref.read(milkingCandidatesProvider).valueOrNull ?? const [];
    return all.where((cow) => draft.selectedIds.contains(cow.id)).toList();
  }

  String _textOf(int cattleId) => (_controllers[cattleId]?.text ?? '').trim();

  void _recompute() {
    final cows = _selectedCows();
    var filled = 0;
    var total = 0.0;

    for (final cow in cows) {
      final text = _textOf(cow.id);
      if (text.isEmpty) continue;
      filled++;
      final value = parseMilkAmount(text);
      if (value != null && value.isFinite && value >= 0) total += value;
    }

    _filled.value = filled;
    _totalLiters.value = total;
    _unfilledCount.value = cows.length - filled;
  }

  /// Переносит введённое в черновик: делаем это перед любым уходом с экрана.
  void _syncDraft() {
    final values = <int, String>{};
    for (final entry in _controllers.entries) {
      values[entry.key] = entry.value.text;
    }
    ref.read(controlMilkingDraftProvider.notifier).setValues(values);
  }

  /// Back возвращает на шаг 1 и сохраняет всё введённое.
  void _onBack() {
    _syncDraft();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/lactation');
    }
  }

  /// Next: значение фиксируется в черновике, фокус уходит к следующей корове,
  /// клавиатура остаётся открытой.
  void _focusNext(List<MilkingCandidate> visible, int index) {
    _syncDraft();

    if (index + 1 >= visible.length) {
      FocusScope.of(context).unfocus();
      return;
    }

    // Запрос фокуса на соседнее поле не закрывает клавиатуру — в отличие от
    // unfocus + requestFocus.
    FocusScope.of(context).requestFocus(_focusFor(visible[index + 1].id));
    _ensureRowVisible(index + 1);
  }

  /// Подтягивает строку в видимую часть списка, если она ушла под клавиатуру
  /// или за верхний край. Строки одной высоты, поэтому позицию считаем
  /// арифметически — это работает и для ещё не построенных элементов.
  void _ensureRowVisible(int index) {
    // Через кадр: к этому моменту вьюпорт уже сжат клавиатурой, а список
    // перестроен после переноса значений в черновик.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final position = _scrollController.position;
      final top = index * _rowExtent;
      final bottom = top + _rowExtent;
      final visibleBottom = position.pixels + position.viewportDimension;

      double? target;
      // Запас в строку, чтобы поле не прилипало к краю над клавиатурой.
      if (bottom + _rowExtent > visibleBottom) {
        target = bottom + _rowExtent - position.viewportDimension;
      } else if (top < position.pixels) {
        target = top;
      }
      if (target == null) return;

      _scrollController.animateTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  List<MilkingCandidate> _visibleCows(List<MilkingCandidate> selected) {
    final snapshot = _unfilledSnapshot;
    if (snapshot == null) return selected;
    return selected.where((cow) => snapshot.contains(cow.id)).toList();
  }

  void _toggleUnfilledFilter(bool onlyUnfilled) {
    setState(() {
      if (!onlyUnfilled) {
        _unfilledSnapshot = null;
        return;
      }
      _unfilledSnapshot = {
        for (final cow in _selectedCows())
          if (_textOf(cow.id).isEmpty) cow.id,
      };
    });
  }

  /// Собирает строки к отправке и помечает некорректные значения.
  ({List<ControlMilkingEntry> entries, Set<int> invalid}) _collect(
    List<MilkingCandidate> cows,
  ) {
    final entries = <ControlMilkingEntry>[];
    final invalid = <int>{};

    for (final cow in cows) {
      final text = _textOf(cow.id);
      // Пустое поле — это "замер не вносили", а не ноль литров.
      if (text.isEmpty) continue;

      final value = parseMilkAmount(text);
      if (value == null || !value.isFinite || value < 0) {
        invalid.add(cow.id);
        continue;
      }
      entries.add(
        ControlMilkingEntry(
          cattleId: cow.id,
          cattleTagNumber: cow.tagNumber,
          liters: value,
        ),
      );
    }

    return (entries: entries, invalid: invalid);
  }

  Future<void> _save() async {
    if (_saving) return;

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final draft = ref.read(controlMilkingDraftProvider);
    final cows = _selectedCows();
    final collected = _collect(cows);

    setState(() => _invalidIds = collected.invalid);

    if (collected.invalid.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.controlMilkingInvalidValue)),
      );
      return;
    }

    if (collected.entries.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.controlMilkingNothingToSave)),
      );
      return;
    }

    final missing = cows.length - collected.entries.length;
    if (missing > 0) {
      final proceed = await _confirmPartial(missing, collected.entries.length);
      if (proceed != true || !mounted) return;
    }

    setState(() => _saving = true);
    try {
      // Ошибка проверки дубликатов прерывает сохранение: молча создать вторую
      // запись на ту же дату хуже, чем попросить повторить попытку.
      final findDuplicates = ref.read(findControlMilkingDuplicatesProvider);
      final duplicates = await findDuplicates(
        date: draft.date,
        milkingTime: draft.milkingTime,
        cattleIds: collected.entries.map((e) => e.cattleId).toSet(),
      );
      if (!mounted) return;

      var action = ControlMilkingDuplicateAction.update;
      if (duplicates.isNotEmpty) {
        final chosen = await _askDuplicateAction(
          count: duplicates.length,
          date: draft.date,
          milkingTime: draft.milkingTime,
        );
        if (chosen == null || !mounted) {
          setState(() => _saving = false);
          return;
        }
        action = chosen;
      }

      final save = ref.read(saveControlMilkingProvider);
      final result = await save(
        date: draft.date,
        milkingTime: draft.milkingTime,
        entries: collected.entries,
        duplicateCattleIds: duplicates,
        duplicateAction: action,
      );

      if (!mounted) return;
      await _handleResult(result);
    } catch (error) {
      if (!mounted) return;
      // Форму не чистим: пользователь должен иметь возможность повторить
      // отправку, не вводя сотню значений заново.
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.controlMilkingSaveErrorTitle}\n'
            '${lactationErrorMessage(error, l10n)}',
          ),
          action: SnackBarAction(
            label: l10n.controlMilkingRetrySave,
            onPressed: _save,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool?> _confirmPartial(int missing, int ready) {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.controlMilkingPartialTitle(missing)),
        content: Text(l10n.controlMilkingPartialMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.controlMilkingPartialContinue),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.controlMilkingPartialSave(ready)),
          ),
        ],
      ),
    );
  }

  Future<ControlMilkingDuplicateAction?> _askDuplicateAction({
    required int count,
    required DateTime date,
    required MilkingTime milkingTime,
  }) {
    final l10n = context.l10n;
    return showDialog<ControlMilkingDuplicateAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.controlMilkingDuplicateTitle),
        content: Text(
          l10n.controlMilkingDuplicateMessage(
            count,
            _dmy.format(date),
            milkingTimeLabel(context, milkingTime),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(ControlMilkingDuplicateAction.keepExisting),
            child: Text(l10n.controlMilkingDuplicateKeep),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(ControlMilkingDuplicateAction.update),
            child: Text(l10n.controlMilkingDuplicateUpdate),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResult(ControlMilkingSaveResult result) async {
    final l10n = context.l10n;
    final litersFormat = NumberFormat('0.##', l10n.localeName);

    if (result.hasFailures) {
      // Успешно отправленные убираем из замера, чтобы повтор не создал их
      // второй раз; неудачные остаются на экране вместе с введёнными литрами.
      if (result.processedCattleIds.isNotEmpty) {
        ref
            .read(controlMilkingDraftProvider.notifier)
            .unselectAll(result.processedCattleIds);
      }
      if (!mounted) return;
      setState(() {});
      _recompute();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.controlMilkingSavePartialFailed(result.failures.length),
          ),
          action: SnackBarAction(
            label: l10n.controlMilkingRetrySave,
            onPressed: _save,
          ),
        ),
      );
      return;
    }

    await showAppSuccessDialog(
      context,
      title: l10n.controlMilkingSavedTitle,
      message: l10n.controlMilkingSavedMessage(
        result.savedCount,
        litersFormat.format(result.savedLiters),
      ),
      buttonText: l10n.lactationGoToList,
    );

    if (!mounted) return;
    ref.read(controlMilkingDraftProvider.notifier).startNew();
    context.go('/lactation');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = ref.watch(controlMilkingDraftProvider);
    // Подписка удерживает список коров живым, пока пользователь на шаге 2.
    final all = ref.watch(milkingCandidatesProvider).valueOrNull ?? const [];
    final selected = all
        .where((cow) => draft.selectedIds.contains(cow.id))
        .toList();
    final visible = _visibleCows(selected);
    final onlyUnfilled = _unfilledSnapshot != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: AppScaffold(
        bottomNavIndex: null,
        farmName: l10n.farmName,
        enableDrawer: false,
        showBell: false,
        backgroundColor: AppColors.primary1,
        body: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          child: Container(
            color: AppColors.background,
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ControlMilkingHeader(step: 2, onBack: _onBack),
                            const SizedBox(height: 10),
                            Text(
                              '${_dmy.format(draft.date)} • '
                              '${milkingTimeLabel(context, draft.milkingTime)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.controlMilkingCowsSelected(selected.length),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.additional3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ControlMilkingChip(
                                  text: l10n.controlMilkingFilterAll,
                                  active: !onlyUnfilled,
                                  onTap: () => _toggleUnfilledFilter(false),
                                ),
                                const SizedBox(width: 8),
                                ValueListenableBuilder<int>(
                                  valueListenable: _unfilledCount,
                                  builder: (context, count, _) {
                                    return ControlMilkingChip(
                                      // "Не заполнено 0" — бессмысленный
                                      // счётчик, показываем чип без цифры.
                                      text: count == 0
                                          ? l10n.controlMilkingTabUnfilledEmpty
                                          : l10n.controlMilkingTabUnfilled(
                                              count,
                                            ),
                                      active: onlyUnfilled,
                                      onTap: () => _toggleUnfilledFilter(true),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Шапка колонок: слева корова, справа молоко.
                            // Отступы совпадают со строкой списка, поэтому
                            // "Молоко" стоит ровно над полями ввода.
                            Padding(
                              // Шапка живёт в блоке с отступом 24, строки — с
                              // отступом 16 плюс колонка галочки: доводим
                              // края вручную, чтобы колонки совпали.
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 10,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l10n.controlMilkingColumnCow,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.additional3,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 96,
                                    child: Text(
                                      l10n.controlMilkingColumnMilk,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.additional3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                      Expanded(
                        child: visible.isEmpty
                            ? ControlMilkingMessageState(
                                title: l10n.controlMilkingNotFoundTitle,
                                subtitle: l10n.controlMilkingNotFoundSubtitle,
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(bottom: 12),
                                // Свайп по списку не должен закрывать
                                // клавиатуру посреди ввода.
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.manual,
                                itemExtent: _rowExtent,
                                itemCount: visible.length,
                                itemBuilder: (context, index) {
                                  final cow = visible[index];
                                  return _ValueRow(
                                    cow: cow,
                                    controller: _controllerFor(cow.id),
                                    focusNode: _focusFor(cow.id),
                                    isLast: index == visible.length - 1,
                                    hasError: _invalidIds.contains(cow.id),
                                    onSubmitted: () =>
                                        _focusNext(visible, index),
                                    onFocusRequested: () =>
                                        _ensureRowVisible(index),
                                  );
                                },
                              ),
                      ),
                      _BottomPanel(
                        total: selected.length,
                        filled: _filled,
                        liters: _totalLiters,
                        saving: _saving,
                        onSave: _save,
                      ),
                    ],
                  ),
                  if (_saving)
                    const Positioned.fill(
                      child: AbsorbPointer(
                        child: ColoredBox(
                          color: Color(0x33000000),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final MilkingCandidate cow;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLast;
  final bool hasError;
  final VoidCallback onSubmitted;
  final VoidCallback onFocusRequested;

  const _ValueRow({
    required this.cow,
    required this.controller,
    required this.focusNode,
    required this.isLast,
    required this.hasError,
    required this.onSubmitted,
    required this.onFocusRequested,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tag = cow.tagNumber.isEmpty ? l10n.selectCattleNoTag : cow.tagNumber;
    // Кличка — главная строка. Если её нет, место занимает бирка, и вторая
    // строка не рисуется: пустая серая строка только съедала бы высоту.
    final title = cow.name.isEmpty ? tag : cow.name;
    final subtitle = cow.name.isEmpty ? null : tag;

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.additional2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
        child: Row(
          children: [
            // Галочка слева — отдельный от фильтра сигнал "эта корова готова".
            // Перерисовывается только она, а не весь список.
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final filled = value.text.trim().isNotEmpty;
                return SizedBox(
                  width: 20,
                  child: filled
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.success,
                        )
                      : null,
                );
              },
            ),
            const SizedBox(width: 4),
            // Корова — один блок из двух строк, а не две колонки: длинная
            // кличка или бирка иначе ломала бы сетку на узком экране.
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary3,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.additional3,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Высоту задаёт contentPadding, а не SizedBox: при жёсткой высоте
            // InputDecorator прижимает содержимое к верху, и поле уезжает
            // вверх относительно клички.
            SizedBox(
              width: 96,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                // Цифровая клавиатура с точкой и без минуса: отрицательный надой
                // невозможен.
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                // Next ведёт к следующей корове: при 100 животных ручной тап по
                // каждому полю недопустим.
                textInputAction: isLast
                    ? TextInputAction.done
                    : TextInputAction.next,
                onSubmitted: (_) => onSubmitted(),
                onTap: onFocusRequested,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  LengthLimitingTextInputFormatter(7),
                ],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: hasError ? AppColors.error : AppColors.additional2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: hasError ? AppColors.error : AppColors.additional2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Единица измерения живёт снаружи поля: в самом поле только число.
            const SizedBox(
              width: 12,
              child: Text(
                'л',
                style: TextStyle(fontSize: 14, color: AppColors.additional3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final int total;
  final ValueNotifier<int> filled;
  final ValueNotifier<double> liters;
  final bool saving;
  final VoidCallback onSave;

  const _BottomPanel({
    required this.total,
    required this.filled,
    required this.liters,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final litersFormat = NumberFormat('0.##', l10n.localeName);

    return ControlMilkingBottomBar(
      info: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Строки идут вплотную: панель должна занимать минимум высоты,
          // экран и так делится с клавиатурой.
          ValueListenableBuilder<int>(
            valueListenable: filled,
            builder: (context, value, _) => Text(
              l10n.controlMilkingFilledProgress(value, total),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: AppColors.primary3,
              ),
            ),
          ),
          ValueListenableBuilder<double>(
            valueListenable: liters,
            builder: (context, value, _) => Text(
              l10n.controlMilkingTotalVolume(litersFormat.format(value)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.25,
                color: AppColors.additional3,
              ),
            ),
          ),
        ],
      ),
      action: SizedBox(
        height: 44,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary1,
            disabledBackgroundColor: AppColors.additional2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          onPressed: saving ? null : onSave,
          child: Text(
            l10n.save,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

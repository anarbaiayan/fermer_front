import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/masked_date_picker.dart';
import 'package:frontend/features/cattle_events/application/cattle_events_providers.dart';
import 'package:frontend/features/cattle_events/application/planned_events_providers.dart';
import 'package:frontend/features/cattle_events/domain/entities/planned_event.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

enum EventsFilterMode { all, completed, overdue }

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final _dmy = DateFormat('dd.MM.yyyy');

  // как на дизайне: выбираем диапазон
  late DateTime _dateFrom;
  late DateTime _dateTo;

  EventsFilterMode _mode = EventsFilterMode.all;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // дефолт: текущая неделя (можешь поменять как хочешь)
    final start = _startOfWeek(now);
    _dateFrom = DateTime(start.year, start.month, start.day);
    _dateTo = DateTime(
      start.year,
      start.month,
      start.day,
    ).add(const Duration(days: 6));
  }

  DateTime _startOfWeek(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    final diff = (x.weekday - DateTime.monday);
    return x.subtract(Duration(days: diff));
  }

  Future<void> _pickFrom() async {
    final picked = await showMaskedDatePicker(
      context: context,
      initialDate: _dateFrom,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: context.l10n.eventsDateStart,
    );
    if (picked == null) return;

    final normalized = DateTime(picked.year, picked.month, picked.day);
    setState(() {
      _dateFrom = normalized;
      if (_dateTo.isBefore(_dateFrom)) _dateTo = _dateFrom;
    });
  }

  Future<void> _pickTo() async {
    final picked = await showMaskedDatePicker(
      context: context,
      initialDate: _dateTo,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: context.l10n.eventsDateEnd,
    );
    if (picked == null) return;

    final normalized = DateTime(picked.year, picked.month, picked.day);
    setState(() {
      _dateTo = normalized;
      if (_dateTo.isBefore(_dateFrom)) _dateFrom = _dateTo;
    });
  }

  Future<void> _showEventActionsSheet(PlannedEvent e) async {
    final l10n = context.l10n;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final isCompleted = _mode == EventsFilterMode.completed;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(
                    isCompleted
                        ? l10n.eventsAlreadyCompleted
                        : l10n.eventsCompleteEvent,
                  ),
                  subtitle: Text('${e.title} - ${e.cattleName}'),
                  enabled: !isCompleted,
                  onTap: isCompleted
                      ? null
                      : () async {
                          Navigator.of(ctx).pop();

                          try {
                            final complete = ref.read(
                              completeCattleEventProvider,
                            );
                            await complete(e.cattleId, e.id);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.eventsEventCompleted),
                                ),
                              );
                            }
                          } catch (err) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.errorPrefix('$err')),
                                ),
                              );
                            }
                          }
                        },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  title: Text(
                    l10n.eventsDeleteEvent,
                    style: TextStyle(color: AppColors.error),
                  ),
                  subtitle: Text(l10n.eventsCannotUndo),
                  onTap: () async {
                    Navigator.of(ctx).pop();

                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        title: Text(l10n.eventsDeleteConfirm),
                        content: Text(
                          '${e.title}\n${e.cattleName} ${e.cattleTagNumber}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dctx).pop(false),
                            child: Text(l10n.dialogCancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dctx).pop(true),
                            child: Text(
                              l10n.dialogDelete,
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true) return;

                    try {
                      debugPrint(
                        'DELETE TAP: eventId=${e.id}, cattleId=${e.cattleId}, title=${e.title}',
                      );
                      final del = ref.read(deletePlannedEventProvider);
                      await del(e.cattleId, e.id);
                      final currentStatus = _mode == EventsFilterMode.completed
                          ? 'COMPLETED'
                          : 'PENDING';
                      ref.invalidate(plannedEventsProvider(currentStatus));

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.eventsDeleted)),
                        );
                      }
                    } catch (err) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.errorPrefix('$err'))),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // цвет статуса (точка)
  Color _statusDotColor(int daysUntil) {
    if (daysUntil > 0) return AppColors.success; // еще есть время
    if (daysUntil >= -5) return AppColors.warning; // день наступил + 5 дней
    return AppColors.error; // дальше просрочка
  }

  bool _passesMode(PlannedEvent e) {
    switch (_mode) {
      case EventsFilterMode.completed:
        return true;

      case EventsFilterMode.overdue:
        // красные (прошло больше 5 дней)
        return e.daysUntil < -5;

      case EventsFilterMode.all:
        // зеленые + желтые (до -5 включительно)
        return e.daysUntil >= -5;
    }
  }

  // фильтр по диапазону: берем plannedDate и показываем окно -5/+5.
  // В список попадает событие, если его окно пересекается с выбранным диапазоном.
  bool _inSelectedDateRange(PlannedEvent e) {
    final planned = DateTime(
      e.plannedDate.year,
      e.plannedDate.month,
      e.plannedDate.day,
    );
    final windowStart = planned.subtract(const Duration(days: 5));
    final windowEnd = planned.add(const Duration(days: 5));

    final from = DateTime(_dateFrom.year, _dateFrom.month, _dateFrom.day);
    final to = DateTime(_dateTo.year, _dateTo.month, _dateTo.day);

    // пересечение отрезков [windowStart..windowEnd] и [from..to]
    final endsBefore = windowEnd.isBefore(from);
    final startsAfter = windowStart.isAfter(to);
    return !(endsBefore || startsAfter);
  }

  String _formatRangeText(DateTime plannedDate) {
    final start = plannedDate.subtract(const Duration(days: 5));
    final end = plannedDate.add(const Duration(days: 5));
    return '${_dmy.format(start)}  -  ${_dmy.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // какой статус дергать с бэка
    final status = _mode == EventsFilterMode.completed
        ? 'COMPLETED'
        : 'PENDING';
    final eventsAsync = ref.watch(plannedEventsProvider(status));

    return AppScaffold(
      bottomNavIndex: 2,
      enableDrawer: true,
      showBell: true,
      showAppBar: true,
      farmName: l10n.farmName,
      body: AppPage(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // header
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: AppIcons.svg('arrow', size: 32),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.eventsTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary3,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: 12),

                // "Задачи"
                Center(
                  child: Text(
                    l10n.eventsTasks,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.primary1),
                const SizedBox(height: 12),

                // date range row (from - to)
                Row(
                  children: [
                    Expanded(
                      child: _DateBox(
                        text: _dmy.format(_dateFrom),
                        onTap: _pickFrom,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.additional3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateBox(
                        text: _dmy.format(_dateTo),
                        onTap: _pickTo,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // круги: завершенные / просроченные
                Row(
                  children: [
                    _CircleOption(
                      label: l10n.eventsCompleted,
                      circleSize: 24,
                      borderWidth: 2,
                      innerDotSize: 11,
                      gap: 10,
                      selected: _mode == EventsFilterMode.completed,
                      onTap: () {
                        setState(() {
                          _mode = (_mode == EventsFilterMode.completed)
                              ? EventsFilterMode.all
                              : EventsFilterMode.completed;
                        });
                      },
                    ),
                    const SizedBox(width: 40),
                    _CircleOption(
                      label: l10n.eventsOverdue,
                      circleSize: 24,
                      borderWidth: 2,
                      innerDotSize: 11,
                      gap: 10,
                      selected: _mode == EventsFilterMode.overdue,
                      onTap: () {
                        setState(() {
                          _mode = (_mode == EventsFilterMode.overdue)
                              ? EventsFilterMode.all
                              : EventsFilterMode.overdue;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: eventsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text(
                        l10n.errorPrefix('$e'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.additional3),
                      ),
                    ),
                    data: (all) {
                      final filtered = all
                          .where(_passesMode)
                          .where(_inSelectedDateRange)
                          .toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.eventsNone,
                            style: TextStyle(
                              color: AppColors.additional3,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.only(top: 6, bottom: 90),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final e = filtered[i];

                          final dotColor = _statusDotColor(e.daysUntil);
                          final circleColor = _categoryColorFromApi(
                            e.cattleCategory,
                          );
                          final iconName = _categoryIconFromApi(
                            e.cattleCategory,
                          );

                          final rangeText = _formatRangeText(e.plannedDate);

                          final primaryHint = _eventActionText(
                            e.eventType,
                            l10n,
                          );
                          final secondary = _eventSecondaryHintIfOverdue(
                            e.daysUntil,
                            l10n,
                          );

                          return _EventCard(
                            circleColor: circleColor,
                            dotColor: dotColor,
                            title: e.title,
                            cattleName: e.cattleName,
                            cattleTag: '#${e.cattleTagNumber}',
                            dateRangeText: rangeText,
                            iconName: iconName,
                            primaryHint: primaryHint,
                            secondaryHint: secondary,
                            secondaryHintColor: AppColors.error,
                            onTap: () => _showEventActionsSheet(e),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // FAB "+"
            Positioned(
              right: 14,
              bottom: 24,
              child: SizedBox(
                width: 56,
                height: 56,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary1, // как на скрине
                  shape: const CircleBorder(),
                  onPressed: () {
                    context.go('/events/bulk/add');
                  },

                  child: SizedBox(
                    width: 63,
                    height: 63,
                    child: Center(
                      child: AppIcons.svg(
                        'plus',
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _DateBox({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.additional2),
        ),
        child: Row(
          children: [
            AppIcons.svg('calendar', size: 18, color: AppColors.additional3),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double circleSize;
  final double borderWidth;
  final double innerDotSize;
  final double gap;

  const _CircleOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.circleSize = 24,
    this.borderWidth = 2.4,
    this.innerDotSize = 11,
    this.gap = 10,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary1 : AppColors.additional2,
                width: borderWidth,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: innerDotSize,
                      height: innerDotSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary1,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.additional3,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Color circleColor;
  final Color dotColor;

  final String title;
  final String cattleName;
  final String cattleTag;

  final String dateRangeText;
  final String iconName;

  final String primaryHint;
  final String? secondaryHint;
  final Color? secondaryHintColor;

  final VoidCallback? onTap;

  const _EventCard({
    required this.circleColor,
    required this.dotColor,
    required this.title,
    required this.cattleName,
    required this.cattleTag,
    required this.dateRangeText,
    required this.iconName,
    required this.primaryHint,
    this.secondaryHint,
    this.secondaryHintColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.06),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcons.svg(iconName, size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: AppColors.additional2),
                    const SizedBox(height: 10),

                    Text(
                      cattleName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cattleTag,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateRangeText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      primaryHint,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.additional3,
                      ),
                    ),

                    if (secondaryHint != null &&
                        secondaryHint!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        secondaryHint!,
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryHintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// helpers: category -> icon/color (как у тебя)
Color _categoryColorFromApi(String? category) {
  switch (category) {
    case 'BULL':
      return const Color(0xFF4A78C1);
    case 'CALF':
      return const Color(0xFFF7DFA3);
    case 'COW':
      return const Color(0xFFB7E4C7);
    case 'HEIFER':
      return const Color(0xFFF4C2C2);
    default:
      return AppColors.additional2;
  }
}

String _categoryIconFromApi(String? category) {
  switch (category) {
    case 'BULL':
      return 'bull_list';
    case 'COW':
      return 'cow_list';
    case 'HEIFER':
      return 'heifer_list';
    case 'CALF':
    default:
      return 'calf_list';
  }
}

String _eventActionText(String eventType, dynamic l10n) {
  switch (eventType) {
    case 'HEAT_PERIOD':
      return l10n.eventTaskHeatPeriod;
    case 'PREGNANCY_CONFIRMATION':
      return l10n.eventTaskPregnancyCheck;
    case 'DRY_PERIOD':
      return l10n.eventTaskDryPeriod;
    case 'WEIGHING':
      return l10n.eventTaskWeighing;
    case 'VACCINATION':
      return l10n.eventTaskVaccination;
    case 'ILLNESS_TREATMENT':
      return l10n.eventTaskTreatment;
    case 'HOOF_TRIMMING':
      return l10n.eventTaskHoofTrimming;
    case 'ANTIPARASITIC_TREATMENT':
      return l10n.eventTaskAntiparasitic;
    case 'CALVING':
      return l10n.eventTaskCalvingFollowUp;
    case 'INSEMINATION':
      return l10n.eventTaskInsemination;
    case 'WEANING':
      return l10n.eventTaskWeaning;
    case 'OTHER':
    default:
      return l10n.eventTaskDefault;
  }
}

String _eventSecondaryHintIfOverdue(int daysUntil, dynamic l10n) {
  if (daysUntil < -5) return l10n.eventOverdueHint;
  return '';
}

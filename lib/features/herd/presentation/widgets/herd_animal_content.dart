import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/features/cattle_events/application/cattle_events_providers.dart';
import 'package:frontend/features/cattle_events/data/datasources/cattle_events_api.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/data/datasources/herd_api.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/presentation/widgets/cattle_events_preview.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';
import 'package:frontend/features/herd/presentation/utils/cattle_formatters.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_small_action_card.dart';
import 'package:frontend/features/herd/domain/entities/bull_purpose.dart';
import 'package:frontend/features/lactation/application/lactation_providers.dart';
import 'package:frontend/features/rations/application/rations_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class HerdAnimalContent extends ConsumerStatefulWidget {
  final Cattle cattle;
  final VoidCallback onAddEvent;

  const HerdAnimalContent({
    super.key,
    required this.cattle,
    required this.onAddEvent,
  });

  @override
  ConsumerState<HerdAnimalContent> createState() => _HerdAnimalContentState();
}

class _HerdAnimalContentState extends ConsumerState<HerdAnimalContent> {
  bool _showAllUpcoming = false;
  final Set<int> _completedUpcomingIds = {};
  bool _isDeleting = false;

  // ✅ новое: загрузка при регенерации рациона
  bool _isRegenerating = false;

  Future<void> _confirmDelete(BuildContext context) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Удалить животное?'),
            content: const Text('Это действие нельзя отменить. Вы уверены?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Удалить'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    await _deleteCattle(context);
  }

  Future<void> _deleteCattle(BuildContext context) async {
    final cattle = widget.cattle;

    setState(() => _isDeleting = true);

    try {
      final api = ref.read(herdApiProvider);
      await api.deleteCattle(cattle.id);

      ref.invalidate(cattleListProvider);
      ref.invalidate(cattleStatisticsProvider);
      ref.invalidate(cattleDetailsProvider(cattle.id));
      ref.invalidate(cattleByIdProvider(cattle.id));

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Животное удалено')));
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  // ✅ новое: регенерация рациона + overlay + success dialog
  Future<void> _regenerateRation() async {
    if (_isRegenerating) return;

    setState(() => _isRegenerating = true);
    _showFullScreenLoading(text: 'Генерируется рацион...');

    try {
      final cattle = widget.cattle;
      final regen = ref.read(regenerateCattleRationProvider);

      await regen(cattle.id);

      if (!mounted) return;

      ref.invalidate(cattleRationByCattleProvider(cattle.id));
      ref.invalidate(cattleRationsProvider);

      _hideFullScreenLoading();

      await showAppSuccessDialog(
        context,
        title: 'Рацион успешно\nсгенерирован заново!',
        message: 'Обновленные данные сохранены.',
        buttonText: 'Понятно',
      );
    } catch (e) {
      if (!mounted) return;
      _hideFullScreenLoading();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _isRegenerating = false);
    }
  }

  void _showFullScreenLoading({String text = 'Генерируется рацион...'}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, // ✅ перекрывает и AppBar тоже
      builder: (_) => _FullScreenLoadingDialog(text: text),
    );
  }

  void _hideFullScreenLoading() {
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cattle = widget.cattle;
    final resolved = AnimalCategoryResolver.resolve(
      gender: cattle.gender,
      dateOfBirth: cattle.dateOfBirth,
    );
    final category = resolved.category;
    final isCow = category == AnimalCategory.cow;
    final isHeifer = category == AnimalCategory.heifer;
    final isBull = category == AnimalCategory.bull;

    final headerColor = _categoryColor(category);

    final ageMonths = resolved.ageInMonths;
    final ageText = formatAge(ageMonths);
    final detailsAsync = ref.watch(cattleDetailsProvider(cattle.id));
    final details = detailsAsync.value; // может быть null пока грузится
    final healthText = mapHealthStatus(details?.healthStatus);

    final tagText = '#${cattle.tagNumber}';
    final birthDateText = DateFormat('dd.MM.yyyy').format(cattle.dateOfBirth);

    String pregnancyLabel(bool? v) =>
        v == null ? '—' : (v ? 'Беременна' : 'Не беременна');

    String reproductiveLabel(String? raw) {
      switch (raw) {
        case 'OPEN':
          return 'Не осеменена';
        case 'INSEMINATED':
          return 'Осеменена';
        case 'PREGNANT':
          return 'Беременна';
        case 'DRY_PERIOD':
          return 'Сухостой';
        case 'CALVING_SOON':
          return 'Скоро отёл';
        case 'FRESH_COW':
          return 'Свежая корова';
        default:
          return '—';
      }
    }

    String productionLabel(String? raw) {
      switch (raw) {
        case 'LACTATING':
          return 'Лактация';
        case 'DRY_PHASE_1':
          return 'Сухостой (фаза 1)';
        case 'DRY_PHASE_2':
          return 'Сухостой (фаза 2)';
        case 'DRY':
          return 'Сухостой';
        case 'FATTENING':
          return 'На откорме';
        case 'BREEDING':
          return 'Племенное использование';
        case 'UNKNOWN':
          return 'Неизвестно';
        default:
          return '—';
      }
    }

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: AppIcons.svg('arrow', size: 32),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Информация о животном',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                          color: AppColors.additional2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.04),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  headerColor.withOpacity(0.35),
                                  Colors.white,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: SizedBox(
                              height: 32,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      cattle.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary3,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: AppIcons.svg('dots', size: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _confirmDelete(context);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Удалить',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(
                            height: 0.5,
                            color: AppColors.additional2,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 12),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.additional2,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: AppIcons.svg('info', size: 34),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Основная информация',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary3,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: AppIcons.svg('edit', size: 30),
                                    onPressed: () {
                                      context.push('/herd/edit', extra: cattle);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRowOptional('Бирка', tagText),
                                _infoRowOptional(
                                  'Дата рождения',
                                  birthDateText,
                                ),
                                _infoRowOptional('Возраст', ageText),
                                _infoRowOptional(
                                  'Категория',
                                  _categoryTitle(category),
                                ),
                                _infoRowOptional('Порода', details?.breed),
                                _infoRowOptional(
                                  'Группа',
                                  details?.animalGroup,
                                ),
                                _healthInfoRowOptional(
                                  'Состояние здоровья',
                                  healthText,
                                ),

                                if (isCow) ...[
                                  _infoRowMilkOptional(
                                    'Последний надой\n(л/день)',
                                    details?.lastMilkYield,
                                  ),
                                  _infoRowDateOptional(
                                    'Дата последнего\nнадоя',
                                    details?.lastMilkYieldDate,
                                  ),
                                  _infoRowMilkOptional(
                                    'Средний надой\nза 7 дней',
                                    details?.averageMilkYield7Days,
                                  ),
                                  _infoRowMilkOptional(
                                    'Средний надой\nза 30 дней',
                                    details?.averageMilkYield30Days,
                                  ),
                                  _infoRowMilkOptional(
                                    'Пик надоя\n(текущая лактация)',
                                    details?.peakMilkYieldCurrentLactation,
                                  ),
                                  _infoRowMilkOptional(
                                    'Всего молока\n(текущая лактация)',
                                    details?.totalMilkCurrentLactation,
                                  ),
                                  _infoRowDateOptional(
                                    'Последний отел',
                                    details?.lastCalvingDate,
                                  ),
                                  _infoRowDateOptional(
                                    'Последнее\nосеменение',
                                    details?.lastInseminationDate,
                                  ),
                                  if (details?.isPregnant != null)
                                    _infoRowOptional(
                                      'Беременность',
                                      pregnancyLabel(details?.isPregnant),
                                    ),
                                  _infoRowOptional(
                                    'Репродуктивный статус',
                                    (details?.reproductiveState == null)
                                        ? null
                                        : reproductiveLabel(
                                            details?.reproductiveState,
                                          ),
                                  ),
                                  _infoRowOptional(
                                    'Производственный статус',
                                    (details?.productionState == null)
                                        ? null
                                        : productionLabel(
                                            details?.productionState,
                                          ),
                                  ),
                                ],

                                if (isHeifer) ...[
                                  _infoRowDateOptional(
                                    'Первое\nосеменение',
                                    details?.firstInseminationDate,
                                  ),
                                  _infoRowDateOptional(
                                    'Планируемая дата\nотела',
                                    details?.expectedCalvingDate,
                                  ),
                                  if (details?.isPregnant != null)
                                    _infoRowOptional(
                                      'Беременность',
                                      pregnancyLabel(details?.isPregnant),
                                    ),
                                  _infoRowOptional(
                                    'Репродуктивный статус',
                                    (details?.reproductiveState == null)
                                        ? null
                                        : reproductiveLabel(
                                            details?.reproductiveState,
                                          ),
                                  ),
                                ],

                                if (isBull) ...[
                                  _infoRowOptional(
                                    'Назначение',
                                    details?.bullPurpose?.display,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SmallActionCard(
                                    title: 'Сгенерировать рацион повторно',
                                    subtitle: 'Примерно 1 минута',
                                    icon: AppIcons.svg('actions', size: 26),
                                    onTap: _isRegenerating
                                        ? () {}
                                        : _regenerateRation,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SmallActionCard(
                                    title: 'Посмотреть рацион',
                                    subtitle: 'Выберите рацион',
                                    icon: AppIcons.svg('diet', size: 26),
                                    onTap: () => context.push(
                                      '/rations',
                                      extra: {'cattleId': cattle.id},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            child: CattleEventsPreview(
                              cattleId: cattle.id,
                              onAddPressed: () async {
                                final res = await context.push<bool>(
                                  '/herd/${cattle.id}/events/add',
                                );

                                if (res == true) {
                                  ref.invalidate(
                                    cattleEventsPreviewProvider(cattle.id),
                                  );
                                  ref.invalidate(
                                    cattleDetailsProvider(cattle.id),
                                  );
                                  ref.invalidate(cattleByIdProvider(cattle.id));
                                  ref.invalidate(cattleListProvider);
                                  ref.invalidate(cattleStatisticsProvider);
                                }
                              },
                            ),
                          ),

                          if ((details?.upcomingEvents?.isNotEmpty ?? false))
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Ближайшие события',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...(() {
                                    final upcomingAll = details!.upcomingEvents!
                                        .where(
                                          (e) => !_completedUpcomingIds
                                              .contains(e.id),
                                        )
                                        .toList();

                                    final visible = _showAllUpcoming
                                        ? upcomingAll
                                        : upcomingAll.take(1);

                                    return visible.map((e) {
                                      final date = e.plannedDate == null
                                          ? '—'
                                          : DateFormat(
                                              'dd.MM.yyyy',
                                            ).format(e.plannedDate!);

                                      final left = e.daysUntil == null
                                          ? ''
                                          : 'через ${e.daysUntil} дн';
                                      final eventId = e.id;

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Dismissible(
                                          key: ValueKey('upcoming_$eventId'),
                                          direction:
                                              DismissDirection.startToEnd,
                                          background: Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(
                                              left: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.success
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: AppColors.success,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Завершить',
                                                  style: TextStyle(
                                                    color: AppColors.primary3,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          confirmDismiss: (_) async {
                                            final ok =
                                                await showDialog<bool>(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text(
                                                      'Завершить событие?',
                                                    ),
                                                    content: Text(
                                                      'Отметить "${e.title}" как выполненное?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(false),
                                                        child: const Text(
                                                          'Отмена',
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(true),
                                                        child: const Text(
                                                          'Завершить',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ) ??
                                                false;

                                            if (!ok) return false;

                                            try {
                                              final api = ref.read(
                                                cattleEventsApiProvider,
                                              );
                                              await api.completeEvent(
                                                eventId: eventId,
                                              );

                                              if (mounted) {
                                                setState(
                                                  () => _completedUpcomingIds
                                                      .add(eventId),
                                                );
                                              }

                                              ref.invalidate(
                                                cattleDetailsProvider(
                                                  cattle.id,
                                                ),
                                              );
                                              ref.invalidate(
                                                cattleEventsPreviewProvider(
                                                  cattle.id,
                                                ),
                                              );

                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Событие завершено',
                                                    ),
                                                  ),
                                                );
                                              }

                                              return true;
                                            } catch (err) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Ошибка: $err',
                                                    ),
                                                  ),
                                                );
                                              }
                                              return false;
                                            }
                                          },
                                          onDismissed: (_) {
                                            ref.invalidate(
                                              cattleByIdProvider(cattle.id),
                                            );
                                            ref.invalidate(cattleListProvider);
                                            ref.invalidate(
                                              cattleStatisticsProvider,
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: AppColors.additional2,
                                                ),
                                                color: const Color(0xFFF9FAFB),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      e.title,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors.primary3,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        date,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .additional3,
                                                        ),
                                                      ),
                                                      if (left.isNotEmpty)
                                                        Text(
                                                          left,
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .additional3,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  })(),
                                  if (details!.upcomingEvents!.length > 1)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton(
                                        onPressed: () {
                                          setState(
                                            () => _showAllUpcoming =
                                                !_showAllUpcoming,
                                          );
                                        },
                                        child: Text(
                                          _showAllUpcoming
                                              ? 'Скрыть'
                                              : 'Показать все (${details.upcomingEvents!.length})',
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          if (isCow)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: _MilkProductivityPreview(
                                cattleId: cattle.id,
                                cattleTagNumber: cattle.tagNumber,
                                onAddPressed: () async {
                                  final res = await context.push<bool>(
                                    '/herd/${cattle.id}/lactation/add',
                                    extra: {
                                      'cattleId': cattle.id,
                                      'cattleTagNumber': cattle.tagNumber,
                                    },
                                  );

                                  if (res == true) {
                                    ref.invalidate(
                                      lactationsByCattleProvider(cattle.id),
                                    );
                                    ref.invalidate(
                                      cattleDetailsProvider(cattle.id),
                                    );
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.only(top: 12),
                child: FermerPlusBigButton(
                  text: 'Закрыть',
                  height: 50,
                  borderRadius: 5,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ],
        ),

        if (_isDeleting)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    );
  }

  Color _categoryColor(AnimalCategory? category) {
    switch (category) {
      case AnimalCategory.bull:
        return const Color(0xFF4A78C1);
      case AnimalCategory.calf:
        return const Color(0xFFF7DFA3);
      case AnimalCategory.cow:
        return const Color(0xFFB7E4C7);
      case AnimalCategory.heifer:
        return const Color(0xFFF4C2C2);
      default:
        return AppColors.additional2;
    }
  }

  String _categoryTitle(AnimalCategory? category) {
    switch (category) {
      case AnimalCategory.cow:
        return 'Корова';
      case AnimalCategory.heifer:
        return 'Тёлка';
      case AnimalCategory.bull:
        return 'Бык';
      case AnimalCategory.calf:
        return 'Телёнок';
      default:
        return '—';
    }
  }

  bool _hasText(String? v) =>
      v != null && v.trim().isNotEmpty && v.trim() != '—';

  Widget _infoRowOptional(String label, String? value) {
    if (!_hasText(value)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value!.trim(),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowDateOptional(String label, DateTime? date) {
    if (date == null) return const SizedBox.shrink();
    return _infoRowOptional(label, DateFormat('dd.MM.yyyy').format(date));
  }

  Widget _infoRowMilkOptional(String label, double? v) {
    if (v == null) return const SizedBox.shrink();
    return _infoRowOptional(label, '${v.toStringAsFixed(0)} л');
  }

  Widget _healthInfoRowOptional(String label, String? text) {
    if (!_hasText(text)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text!.trim(),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilkProductivityPreview extends StatelessWidget {
  final int cattleId;
  final String cattleTagNumber;
  final VoidCallback onAddPressed;

  const _MilkProductivityPreview({
    required this.cattleId,
    required this.cattleTagNumber,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: AppIcons.svg('lactation_number')),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Молочная продуктивность коровы',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: AppIcons.svg('add_event', size: 30),
              onPressed: onAddPressed,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.additional2),
        const SizedBox(height: 8),
        const Text(
          'Добавьте надой (утро/вечер), чтобы вести лактацию.',
          style: TextStyle(fontSize: 14, color: AppColors.additional3),
        ),
      ],
    );
  }
}

class _FullScreenLoadingDialog extends StatelessWidget {
  final String text;
  const _FullScreenLoadingDialog({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

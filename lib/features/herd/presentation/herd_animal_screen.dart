import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/fermer_plus_app_bar.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class HerdAnimalScreen extends ConsumerWidget {
  final int id;

  const HerdAnimalScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cattleAsync = ref.watch(cattleByIdProvider(id));

    return Scaffold(
      backgroundColor: AppColors.primary1, // тот же зелёный, что и у appBar
      appBar: const FermerPlusAppBar(),
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(10), // или 12 – подгони под макет
        ),
        child: Container(
          color: AppColors.background, // фон «карты» страницы
          child: AppPage(
            // AppPage оставляем как есть
            child: cattleAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ошибка при загрузке карточки',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.additional3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref.invalidate(cattleByIdProvider(id)),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
              data: (cattle) => _HerdAnimalContent(cattle: cattle),
            ),
          ),
        ),
      ),
    );
  }
}

class _HerdAnimalContent extends StatelessWidget {
  final Cattle cattle;

  const _HerdAnimalContent({required this.cattle});

  @override
  Widget build(BuildContext context) {
    final resolved = AnimalCategoryResolver.resolve(
      gender: cattle.gender,
      dateOfBirth: cattle.dateOfBirth,
    );
    final ageMonths = resolved.ageInMonths;
    final ageText = _formatAge(ageMonths);

    final details = cattle.details;
    final healthRaw = details?.healthStatus;
    final healthText = _mapHealthStatus(healthRaw);

    final tagText = '#${cattle.tagNumber}';
    final birthDateText = DateFormat('dd.MM.yyyy').format(cattle.dateOfBirth);

    return Column(
      children: [
        // верхняя часть - скролл
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // верхняя строка: назад + заголовок
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
                    const SizedBox(width: 48), // симметрия под иконку слева
                  ],
                ),

                const SizedBox(height: 12),

                // ОДНА большая карточка, как в дизайне
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: AppColors.additional2),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // шапка с именем и градиентом
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromRGBO(247, 223, 163, 0.4),
                              const Color.fromRGBO(255, 255, 255, 1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: SizedBox(
                          height:
                              32, // чтобы было место и для текста, и для кнопки
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // имя строго по центру
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

                              // иконка "три точки" в правом верхнем углу
                              Positioned(
                                right: 10,
                                top: 10,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: AppIcons.svg('dots', size: 20),
                                  onPressed: () {
                                    // TODO: меню действий
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(height: 0.5, color: AppColors.additional2),

                      // "Основная информация"
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

                      // данные
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow('Бирка', tagText),
                            _infoRow('Дата рождения', birthDateText),
                            _infoRow('Возраст', ageText),
                            _infoRow('Порода', details?.breed),
                            _infoRow('Группа', details?.animalGroup),
                            _healthInfoRow('Состояние здоровья', healthText),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // блок с двумя кнопками - внутри той же карточки
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SmallActionCard(
                                title: 'Действия',
                                subtitle: 'Доп. информация',
                                icon: AppIcons.svg('actions', size: 26),
                                onTap: () {
                                  // TODO
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SmallActionCard(
                                title: 'Рацион     ',
                                subtitle: 'Выберите рацион',
                                icon: AppIcons.svg('diet', size: 26),
                                onTap: () {
                                  // TODO
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Журнал событий - тоже внутри той же карточки
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: AppIcons.svg('clock', size: 34),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Журнал событий',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary3,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: AppIcons.svg("add_event", size: 30),
                                  onPressed: () {
                                    // TODO: добавить событие
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(
                              height: 1,
                              color: AppColors.additional2,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Пока нет событий',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.additional3,
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

        // нижняя фиксированная кнопка "Закрыть"
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
    );
  }

  Widget _infoRow(String label, String? value) {
    if (value == null || value.isEmpty) {
      value = '—';
    }
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
              value,
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

  Widget _healthInfoRow(String label, String? text) {
    if (text == null || text.isEmpty) {
      return _infoRow(label, null);
    }
    return Row(
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
          decoration: BoxDecoration(shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.primary3,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  String _formatAge(int months) {
    if (months < 12) {
      return '$months месяцев';
    }
    final years = months ~/ 12;
    final remMonths = months % 12;

    String yearsPart;
    if (years == 1) {
      yearsPart = '1 год';
    } else if (years >= 2 && years <= 4) {
      yearsPart = '$years года';
    } else {
      yearsPart = '$years лет';
    }

    if (remMonths == 0) return yearsPart;
    return '$yearsPart $remMonths месяцев';
  }

  String? _mapHealthStatus(String? raw) {
    if (raw == null) return null;
    switch (raw) {
      case 'HEALTHY':
        return 'Здоров';
      case 'SICK':
        return 'Болен';
      case 'UNDER_TREATMENT':
        return 'На лечении';
      case 'QUARANTINE':
        return 'Карантин';
      case 'RECOVERING':
        return 'Выздоравливает';
      default:
        return null;
    }
  }
}

class _SmallActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback onTap;

  const _SmallActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.additional2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // слева иконка
            Transform.translate(
              offset: const Offset(0, -4),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Center(child: icon),
              ),
            ),
            const SizedBox(width: 12),

            // справа тексты
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + стрелка в одной строке
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary3,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: AppIcons.svg(
                              'arrow2',
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  // подпись под заголовком — теперь тянется до конца
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.additional3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

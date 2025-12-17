import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QuantitySummarySection extends ConsumerWidget {
  const QuantitySummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(cattleStatisticsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Ошибка при загрузке данных по количеству:\n$err',
          style: const TextStyle(fontSize: 13, color: AppColors.additional3),
        ),
      ),
      data: (stats) {
        final total = stats.total;

        final cows = stats.cows;
        final heifers = stats.heifers;
        final bulls = stats.bulls;
        final calves = stats.calves;
        final fattening = stats.fattening;
        final removed = stats.derived; // "derived" = выведенные

        final groupsCount = [
          cows,
          heifers,
          bulls,
          calves,
          fattening,
          removed,
        ].where((v) => v > 0).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- Карточка "Количество" -----
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: AppIcons.svg("reverse-cow", size: 30)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Количество',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Всего скота: $total',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () =>
                                ref.invalidate(cattleStatisticsProvider),
                            child: AppIcons.svg("refresh", size: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ----- Заголовок "Группы" -----
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(
                    "assets/image/group-img.png",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Группы',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Всего групп: $groupsCount',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 54,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        // TODO: переход на экран групп
                      },
                      child: Row(
                        children: [
                          const Text(
                            'Посмотреть',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.additional1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AppIcons.svg(
                            "arrow2",
                            size: 12,
                            color: AppColors.additional1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Column(
              children: [
                const SizedBox(height: 8),
                _GroupPair(
                  left: _GroupCell(
                    title: 'Коровы',
                    value: cows,
                    valueColor: const Color.fromRGBO(47, 108, 168, 1),
                  ),
                  right: _GroupCell(
                    title: 'Тёлки',
                    value: heifers,
                    valueColor: const Color.fromRGBO(238, 102, 31, 1),
                  ),
                ),
                const SizedBox(height: 4),
                _GroupPair(
                  left: _GroupCell(
                    title: 'Быки',
                    value: bulls,
                    valueColor: const Color.fromRGBO(166, 95, 58, 1),
                  ),
                  right: _GroupCell(
                    title: 'Телята',
                    value: calves,
                    valueColor: const Color.fromRGBO(19, 186, 186, 1),
                  ),
                ),
                const SizedBox(height: 4),
                _GroupPair(
                  left: _GroupCell(
                    title: 'Откормочные',
                    value: fattening,
                    valueColor: const Color.fromRGBO(74, 174, 98, 1),
                  ),
                  right: _GroupCell(
                    title: 'Выведенные',
                    value: removed,
                    valueColor: const Color.fromRGBO(74, 76, 76, 1),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _GroupCell extends StatelessWidget {
  final String title;
  final int value;
  final Color valueColor;

  const _GroupCell({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0), // как в макете
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(213, 215, 218, 0.22),
            offset: Offset(0, 4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color.fromRGBO(213, 215, 218, 0.4),
            offset: Offset(0, -2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.additional2, width: 1),
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
              Container(
                width: 40,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromRGBO(213, 215, 218, 0.4),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: AppIcons.svg("arrow2", size: 22, color: valueColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

class _GroupPair extends StatelessWidget {
  final _GroupCell left;
  final _GroupCell right;

  const _GroupPair({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          Container(width: 1, color: AppColors.additional2),
          Expanded(child: right),
        ],
      ),
    );
  }
}

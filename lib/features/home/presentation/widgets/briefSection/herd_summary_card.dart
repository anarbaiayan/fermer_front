import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/theme/app_colors.dart';

class HerdSummaryCard extends StatelessWidget {
  final int totalAnimals;
  final String lastUpdated;
  final VoidCallback? onRefresh;
  final VoidCallback? onDetails;

  const HerdSummaryCard({
    super.key,
    this.totalAnimals = 128,
    this.lastUpdated = '1 час назад',
    this.onRefresh,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // левая колонка - SVG иконка коровы
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary2, // коричневый фон
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppIcons.svg('cow', size: 30),
          ),

          const SizedBox(width: 20),

          // центр - контент
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Сводка стада',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Всего животных: $totalAnimals',
                  style: TextStyle(fontSize: 14, color: AppColors.primary3),
                ),
                const SizedBox(height: 2),
                Text(
                  'Обновлено: $lastUpdated',
                  style: TextStyle(fontSize: 14, color: AppColors.primary3),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: 140,
                  height: 36,
                  child: FermerPlusSmallButton(
                    text: 'Подробнее',
                    onPressed: onDetails ?? () {},
                    height: 30,
                    width: 123,
                    backgroundColor: AppColors.primary1,
                  ),
                ),
              ],
            ),
          ),

          // правая колонка — обновление
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: onRefresh ?? () {},
            icon: AppIcons.svg('refresh', size: 19)
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_card.dart';

class HerdSummaryCard extends StatelessWidget {
  final int totalAnimals;
  final String lastUpdated;
  final VoidCallback? onRefresh;
  final VoidCallback? onDetails;

  const HerdSummaryCard({
    super.key,
    this.totalAnimals = 0,
    this.lastUpdated = '—',
    this.onRefresh,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppIcons.svg('cow', size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.herdSummaryTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.herdTotalAnimals(totalAnimals),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.herdUpdated(lastUpdated),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary3,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 140,
                  height: 36,
                  child: FermerPlusSmallButton(
                    text: l10n.herdDetails,
                    onPressed: onDetails ?? () {},
                    height: 30,
                    width: 123,
                    backgroundColor: AppColors.primary1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: onRefresh ?? () {},
            icon: AppIcons.svg('refresh', size: 19),
          ),
        ],
      ),
    );
  }
}

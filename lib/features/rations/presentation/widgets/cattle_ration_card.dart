import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/production_state.dart';

import '../../data/models/cattle_ration_dto.dart';

enum CattleRationCardVariant { overview, fromCattle }

class CattleRationCard extends StatelessWidget {
  final CattleRationDto ration;
  final Future<void> Function()? onDelete;
  final VoidCallback? onTap;
  final CattleRationCardVariant variant;

  const CattleRationCard({
    super.key,
    required this.ration,
    this.onDelete,
    this.onTap,
    this.variant = CattleRationCardVariant.overview,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = AnimalCategoryX.fromApi(ration.animalCategory ?? '');
    final production = ProductionStateX.fromApi(ration.productionState ?? '');
    final cat = _categoryText(context, category);
    final prod = _productionText(context, production);

    final statusText = ration.isOptimal
        ? l10n.rationStatusActive
        : l10n.rationStatusNeedsAttention;
    final statusColor = ration.isOptimal
        ? AppColors.success
        : AppColors.warning;

    final feedNames = ration.items.map((e) => e.feedName).take(4).join(', ');
    final dailyKg = ration.totalDailyKg.toStringAsFixed(0);

    final circleColor = _categoryColorFromApi(ration.animalCategory);
    final iconName = _categoryIconFromApi(ration.animalCategory);

    final base = Container(
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
      child: variant == CattleRationCardVariant.overview
          ? _OverviewBody(
              iconName: iconName,
              circleColor: circleColor,
              onDelete: onDelete,
              cat: cat,
              prod: prod,
              statusText: statusText,
              statusColor: statusColor,
              feedNames: feedNames,
              dailyKg: dailyKg,
            )
          : _FromCattleBody(
              iconName: iconName,
              circleColor: circleColor,
              onDelete: onDelete,
              title: ration.name ?? '',
              cat: cat,
              prod: prod,
              statusText: statusText,
              statusColor: statusColor,
              feedNames: feedNames,
              dailyKg: dailyKg,
              warnings: (ration.warnings ?? '').trim(),
            ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: base,
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  final String iconName;
  final Color circleColor;
  final Future<void> Function()? onDelete;

  final String cat;
  final String prod;
  final String statusText;
  final Color statusColor;
  final String feedNames;
  final String dailyKg;

  const _OverviewBody({
    required this.iconName,
    required this.circleColor,
    required this.onDelete,
    required this.cat,
    required this.prod,
    required this.statusText,
    required this.statusColor,
    required this.feedNames,
    required this.dailyKg,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: AppIcons.svg(iconName, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.rationCategory(cat),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primary3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.rationPeriod(prod),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primary3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primary3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.rationFeedType(feedNames),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.additional3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.rationDailyNorm(dailyKg),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.additional3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: onDelete == null
              ? null
              : () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        l10n.rationDeleteTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary3,
                        ),
                      ),
                      content: Text(
                        l10n.rationDeleteConfirm,
                        style: const TextStyle(color: AppColors.primary3),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(l10n.dialogCancel),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(l10n.dialogDelete),
                        ),
                      ],
                    ),
                  );

                  if (ok == true) await onDelete!.call();
                },
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
        ),
      ],
    );
  }
}

class _FromCattleBody extends StatelessWidget {
  final String iconName;
  final Color circleColor;
  final Future<void> Function()? onDelete;

  final String title;
  final String cat;
  final String prod;
  final String statusText;
  final Color statusColor;
  final String feedNames;
  final String dailyKg;
  final String warnings;

  const _FromCattleBody({
    required this.iconName,
    required this.circleColor,
    required this.onDelete,
    required this.title,
    required this.cat,
    required this.prod,
    required this.statusText,
    required this.statusColor,
    required this.feedNames,
    required this.dailyKg,
    required this.warnings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppIcons.svg(iconName, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary3,
                ),
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        l10n.rationDeleteTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary3,
                        ),
                      ),
                      content: Text(
                        l10n.rationDeleteConfirm,
                        style: const TextStyle(color: AppColors.primary3),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(l10n.dialogCancel),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(l10n.dialogDelete),
                        ),
                      ],
                    ),
                  );

                  if (ok == true) await onDelete!.call();
                },
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 46),
          child: Divider(height: 1, color: AppColors.additional2),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 46),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.rationCategory(cat),
                style: const TextStyle(fontSize: 13, color: AppColors.primary3),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.rationPeriod(prod),
                style: const TextStyle(fontSize: 13, color: AppColors.primary3),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.rationFeedType(feedNames),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.additional3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.rationDailyNorm(dailyKg),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.additional3,
                ),
              ),
              if (warnings.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  warnings,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

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

String _categoryText(BuildContext context, AnimalCategory category) {
  final l10n = context.l10n;

  switch (category) {
    case AnimalCategory.bull:
      return l10n.rationCategoryBull;
    case AnimalCategory.cow:
      return l10n.rationCategoryCow;
    case AnimalCategory.heifer:
      return l10n.rationCategoryHeifer;
    case AnimalCategory.calf:
      return l10n.rationCategoryCalf;
  }
}

String _productionText(BuildContext context, ProductionState productionState) {
  final l10n = context.l10n;

  switch (productionState) {
    case ProductionState.lactating:
      return l10n.prodStateLactation;
    case ProductionState.dryPhase1:
    case ProductionState.dryPhase2:
      return l10n.prodStateDry;
    case ProductionState.fattening:
      return l10n.prodStateFatteningFull;
    case ProductionState.breeding:
      return l10n.prodStateBreedingFull;
    case ProductionState.unknown:
      return l10n.prodStateUnknown;
  }
}

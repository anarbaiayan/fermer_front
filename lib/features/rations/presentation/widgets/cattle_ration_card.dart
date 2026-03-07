import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import '../../data/models/cattle_ration_dto.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/production_state.dart';

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
    final cat = AnimalCategoryX.fromApi(ration.animalCategory ?? '').display;
    final prod = ProductionStateX.fromApi(ration.productionState ?? '').display;

    final statusText = ration.isOptimal ? 'Активный' : 'Требует внимания';
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

    // В overview карточка НЕ кликается (у тебя onTap: null),
    // но оставим InkWell чтобы в fromCattle работало как раньше.
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
    // ✅ Дизайн "как на скрине":
    // - без заголовка/имени
    // - без верхнего Divider
    // - иконка слева сверху, корзина справа сверху
    // - текст сразу блоком
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
                  'Категория: $cat',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primary3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Период: $prod',
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
                  'Вид корма: $feedNames',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.additional3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Норма в день: $dailyKg кг',
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
                      title: const Text(
                        'Удалить рацион?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary3,
                        ),
                      ),
                      content: const Text(
                        'Вы уверены, что хотите удалить этот рацион? Это действие нельзя отменить.',
                        style: TextStyle(color: AppColors.primary3),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Отмена'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Удалить'),
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
    // ✅ этот режим НЕ меняем (как у тебя было раньше)
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
                      title: const Text(
                        'Удалить рацион?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary3,
                        ),
                      ),
                      content: const Text(
                        'Вы уверены, что хотите удалить этот рацион? Это действие нельзя отменить.',
                        style: TextStyle(color: AppColors.primary3),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Отмена'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Удалить'),
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
                'Категория: $cat',
                style: const TextStyle(fontSize: 13, color: AppColors.primary3),
              ),
              const SizedBox(height: 4),
              Text(
                'Период: $prod',
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
                'Вид корма: $feedNames',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.additional3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Норма в день: $dailyKg кг',
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

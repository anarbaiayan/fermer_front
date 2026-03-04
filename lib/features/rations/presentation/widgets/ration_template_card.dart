import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import '../../data/models/ration_template_dto.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart'; // твой enum
import 'package:frontend/features/herd/domain/entities/production_state.dart'; // если вынес, иначе адаптируй

class RationTemplateCard extends StatelessWidget {
  final RationTemplateDto template;
  final VoidCallback? onTap;
  final Future<void> Function()? onDelete;

  const RationTemplateCard({
    super.key,
    required this.template,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cat = AnimalCategoryX.fromApi(template.animalCategory).display;
    final prod = ProductionStateX.fromApi(template.productionState).display;

    final statusText = template.isOptimal ? 'Активный' : 'Требует внимания';
    final statusColor = template.isOptimal
        ? AppColors.success
        : AppColors.warning;

    final feedNames = template.items
        .map((e) => e.ration.name)
        .take(4)
        .join(', ');
    final dailyKg = template.totalDailyKg.toStringAsFixed(0);
    final dailyCost = template.totalDailyCost.toStringAsFixed(0);

    final circleColor = _categoryColorFromApi(template.animalCategory);
    final iconName = _categoryIconFromApi(template.animalCategory);

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
          child: Column(
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
                    child: AppIcons.svg(
                      iconName,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      template.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary3,
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
                              builder: (ctx) {
                                return AlertDialog(
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
                                  actionsPadding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text(
                                        'Отмена',
                                        style: TextStyle(
                                          color: AppColors.primary3,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: const Text('Удалить'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (ok == true) {
                              await onDelete!.call();
                            }
                          },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(left: 46),
                child: const Divider(height: 1, color: AppColors.additional2),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: EdgeInsets.only(left: 46),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Категория: $cat',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Период: $prod',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Стоимость/день: $dailyCost тг.',
                      style: const TextStyle(
                        fontSize: 13,
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

                    if (template.warnings.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        template.warnings,
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

              if (template.warnings.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  template.warnings,
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
      ),
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
import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';
import 'package:frontend/features/herd/domain/entities/health_status.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HerdListItem extends ConsumerWidget {
  final Cattle cattle;
  final VoidCallback? onTap;

  const HerdListItem({super.key, required this.cattle, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolved = AnimalCategoryResolver.resolve(
      gender: cattle.gender,
      dateOfBirth: cattle.dateOfBirth,
    );
    final category = resolved.category;
    final ageText = _formatAge(resolved.ageInMonths);

    // <- ДОГРУЖАЕМ DETAILS ОТДЕЛЬНО
    final detailsAsync = ref.watch(cattleDetailsProvider(cattle.id));

    // событие (пока как было)
    final tagText = '#${cattle.tagNumber}';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(213, 215, 218, 0.22),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _categoryColor(category),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppIcons.svg(
                _categoryIcon(category),
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cattle.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary3,
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.additional2,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    tagText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    ageText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary3,
                    ),
                  ),

                  // ---- ЗДОРОВЬЕ И СОБЫТИЕ ИЗ DETAILS ----
                  detailsAsync.when(
                    loading: () => const SizedBox(height: 0),
                    error: (_, __) => const SizedBox(height: 0),
                    data: (details) {
                      final raw = details?.healthStatus;
                      HealthStatus? hs;
                      if (raw != null && raw.isNotEmpty) {
                        try {
                          hs = HealthStatusX.fromApi(raw);
                        } catch (_) {
                          hs = null;
                        }
                      }

                      final healthText = hs?.display;
                      final healthColor = _healthColor(hs);

                      final eventText = details?.animalGroup;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hs != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: healthColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  healthText!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary3,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (eventText != null && eventText.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.additional3,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  eventText,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAge(int months) {
    if (months < 12) return '$months месяцев';
    final years = months ~/ 12;
    final rem = months % 12;

    String yearsPart;
    if (years == 1) {
      yearsPart = '1 год';
    } else if (years >= 2 && years <= 4) {
      yearsPart = '$years года';
    } else {
      yearsPart = '$years лет';
    }
    if (rem == 0) return yearsPart;
    return '$yearsPart $rem месяцев';
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

  String _categoryIcon(AnimalCategory? category) {
    switch (category) {
      case AnimalCategory.bull:
        return 'bull_list';
      case AnimalCategory.cow:
        return 'cow_list';
      case AnimalCategory.heifer:
        return 'heifer_list';
      case AnimalCategory.calf:
      default:
        return 'calf_list';
    }
  }
}

Color _healthColor(HealthStatus? hs) {
  switch (hs) {
    case HealthStatus.healthy:
      return AppColors.success;
    case HealthStatus.sick:
      return AppColors.error;
    case HealthStatus.underTreatment:
      return AppColors.warning;
    case HealthStatus.quarantine:
      return AppColors.quarantine;
    case HealthStatus.recovering:
    default:
      return AppColors.additional3;
  }
}

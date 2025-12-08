import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';

class HerdListItem extends StatelessWidget {
  final Cattle cattle;
  final VoidCallback? onTap;

  const HerdListItem({super.key, required this.cattle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final resolved = AnimalCategoryResolver.resolve(
      gender: cattle.gender,
      dateOfBirth: cattle.dateOfBirth,
    );
    final AnimalCategory? category = resolved.category;
    final ageMonths = resolved.ageInMonths;
    final ageText = _formatAge(ageMonths);

    // здоровье
    final healthRaw = cattle.details?.healthStatus;
    final health = _mapHealthStatus(healthRaw);
    final healthColor = _mapHealthColor(healthRaw);

    // событие (пока используем какое-то строковое поле,
    // когда бек добавит конкретное - просто подставишь нужное)
    final String? eventText = cattle.details?.animalGroup;

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
            // ---- Кружок категории слева ----
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _categoryColor(category),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _categoryLetter(category),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ---- Колонка с текстом справа ----
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Имя
                  Text(
                    cattle.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Линия как в макете
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.additional2,
                  ),

                  const SizedBox(height: 12),

                  // Бирка
                  Text(
                    tagText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Возраст
                  Text(
                    ageText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary3,
                    ),
                  ),

                  // Статус здоровья
                  if (health != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: healthColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          health,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary3,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Событие (если есть)
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // возраст: "8 месяцев", "1 год 11 месяцев", "5 лет"
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

  Color _mapHealthColor(String? raw) {
    switch (raw) {
      case 'HEALTHY':
        return AppColors.success;
      case 'SICK':
        return AppColors.error;
      case 'UNDER_TREATMENT':
        return AppColors.warning;
      case 'QUARANTINE':
        return AppColors.quarantine;
      case 'RECOVERING':
      default:
        return AppColors.additional3;
    }
  }

  Color _categoryColor(AnimalCategory? category) {
    switch (category) {
      case AnimalCategory.bull:
        return const Color(0xFFFFE0E5); // розовый
      case AnimalCategory.calf:
        return const Color(0xFFFFF3C4); // жёлтый
      case AnimalCategory.cow:
        return const Color(0xFFCFEAD9); // зелёный
      case AnimalCategory.heifer:
        return const Color(0xFFE5D9FF); // фиолетовый
      default:
        return AppColors.additional2;
    }
  }

  String _categoryLetter(AnimalCategory? category) {
    switch (category) {
      case AnimalCategory.bull:
        return 'Б';
      case AnimalCategory.calf:
        return 'Т'; // телёнок
      case AnimalCategory.cow:
        return 'К';
      case AnimalCategory.heifer:
        return 'Т'; // тёлка
      default:
        return '';
    }
  }
}

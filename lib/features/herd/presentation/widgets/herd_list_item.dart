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
  final bool showHealth;

  const HerdListItem({
    super.key,
    required this.cattle,
    this.onTap,
    this.showHealth = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolved = AnimalCategoryResolver.resolve(
      gender: cattle.gender,
      dateOfBirth: cattle.dateOfBirth,
    );

    final category = resolved.category;
    final ageText = _formatAge(resolved.ageInMonths);
    final tagText = '#${cattle.tagNumber}';
    final nameText = (cattle.name).trim().isEmpty
        ? 'Без имени'
        : cattle.name.trim();

    final detailsAsync = showHealth
        ? ref.watch(cattleDetailsProvider(cattle.id))
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(213, 215, 218, 0.22),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- NAME (TOP) ---
            Align(
              alignment: Alignment.center,
              child: Text(
                nameText,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary3,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- ICON ---
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _categoryColor(category),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppIcons.svg(
                _categoryIcon(category),
                size: 22,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.additional2,
            ),
            const SizedBox(height: 12),

            // --- TAG ---
            Text(
              tagText,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary3,
              ),
            ),
            const SizedBox(height: 6),

            // --- AGE ---
            Text(
              ageText,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.primary3),
            ),

            const SizedBox(height: 12),

            // --- STATUSES + HEALTH (BOTTOM) ---
            if (!showHealth)
              const SizedBox(height: 40)
            else
              detailsAsync!.when(
                loading: () => const SizedBox(height: 40),
                error: (_, __) => const SizedBox(height: 40),
                data: (details) {
                  final statusLine = _buildStatusLine(details);
                  final healthLine = _buildHealthLine(details);

                  // здоровье должно быть "в самом низу"
                  return SizedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (statusLine != null) ...[
                          statusLine,
                          const SizedBox(height: 8),
                        ],
                        healthLine ?? const SizedBox(height: 18),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ---- Status line: reproductive + production ----
  Widget? _buildStatusLine(dynamic details) {
    // details тип у тебя nullable/модель - оставил dynamic чтобы не упереться в импорт dto
    // Поменяй dynamic на конкретный тип, если хочешь: CattleDetails? details
    final repro = (details?.reproductiveState as String?)?.trim();
    final prod = (details?.productionState as String?)?.trim();

    final parts = <String>[];
    final reproLabel = _reproLabel(repro);
    final prodLabel = _prodLabel(prod);

    if (reproLabel != null && reproLabel.isNotEmpty) parts.add(reproLabel);
    if (prodLabel != null && prodLabel.isNotEmpty) parts.add(prodLabel);

    if (parts.isEmpty) return null;

    return Text(
      parts.join(' - '),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.additional3,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ---- Health line: dot + text ----
  Widget? _buildHealthLine(dynamic details) {
    final raw = (details?.healthStatus as String?)?.trim();
    if (raw == null || raw.isEmpty) return null;

    HealthStatus? hs;
    try {
      hs = HealthStatusX.fromApi(raw);
    } catch (_) {
      hs = null;
    }
    if (hs == null) return null;

    final healthColor = _healthColor(hs);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: healthColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            hs.display,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.primary3),
          ),
        ),
      ],
    );
  }

  String? _reproLabel(String? raw) {
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
        return 'Свежая';
      default:
        return null;
    }
  }

  String? _prodLabel(String? raw) {
    switch (raw) {
      case 'LACTATING':
        return 'Лактация';
      case 'DRY':
        return 'Сухостой';
      case 'FATTENING':
        return 'Откорм';
      case 'BREEDING':
        return 'Племенная';
      case 'UNKNOWN':
      default:
        return null;
    }
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

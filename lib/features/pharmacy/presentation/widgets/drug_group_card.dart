import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/pharmacy/data/models/drug_group_dto.dart';
import 'package:frontend/features/pharmacy/presentation/pharmacy_format.dart';
import 'package:frontend/features/pharmacy/presentation/widgets/drug_placeholder_image.dart';

/// Строка каталога: препарат/группа с текстовым описанием и ценой «от …».
class DrugGroupCard extends StatelessWidget {
  final DrugGroupDto group;
  final VoidCallback onTap;

  const DrugGroupCard({super.key, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cheapest = group.cheapestOffer;

    final producer = group.hasComparison
        ? l10n.pharmacyOffers(group.offerCount)
        : (cheapest?.companyName ?? '');
    final subtitle = [
      producer,
      group.actionName,
    ].where((e) => e != null && e.trim().isNotEmpty).join(' · ');

    var priceText = l10n.pharmacyPriceFrom(formatTenge(group.minPrice));
    final packaging = cheapest?.packaging;
    if (packaging != null && packaging.isNotEmpty) {
      priceText = '$priceText / $packaging';
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrugPlaceholderImage(
              imageUrl: cheapest?.imageUrl,
              width: 56,
              height: 56,
              borderRadius: 10,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary3,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.additional3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.background3,
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

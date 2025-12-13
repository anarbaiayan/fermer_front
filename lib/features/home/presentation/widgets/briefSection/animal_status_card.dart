import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/theme/app_colors.dart';

class AnimalStatusCard extends StatelessWidget {
  final int lactating;
  final int dryPeriod;
  final int open;
  final int inseminated;

  const AnimalStatusCard({
    super.key,
    required this.lactating,
    required this.dryPeriod,
    required this.open,
    required this.inseminated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatusItemCard(
                title: 'Дойные',
                badgeColor: Colors.red,
                badgeValue: lactating,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatusItemCard(
                title: 'Сухостой',
                badgeColor: const Color(0xFF3E5BD8),
                badgeValue: dryPeriod,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatusItemCard(
                title: 'Открытые',
                badgeColor: AppColors.success,
                badgeValue: open,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatusItemCard(
                title: 'Осемененные',
                badgeColor: Colors.teal,
                badgeValue: inseminated,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusItemCard extends StatelessWidget {
  final String title;
  final Color badgeColor;
  final int badgeValue;

  const _StatusItemCard({
    required this.title,
    required this.badgeColor,
    required this.badgeValue,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeValue.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Всего: $badgeValue',
            style: TextStyle(fontSize: 12, color: AppColors.primary3),
          ),
        ],
      ),
    );
  }
}

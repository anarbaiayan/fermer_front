import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/theme/app_colors.dart';

class AnimalStatusCard extends StatelessWidget {
  final int milkingCows;
  final int milkingHeifers;
  final int dryCows;
  final int dryHeifers;
  final int openCows;
  final int openHeifers;
  final int inseminatedCows;
  final int inseminatedHeifers;

  const AnimalStatusCard({
    super.key,
    required this.milkingCows,
    required this.milkingHeifers,
    required this.dryCows,
    required this.dryHeifers,
    required this.openCows,
    required this.openHeifers,
    required this.inseminatedCows,
    required this.inseminatedHeifers,
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
                badgeValue: milkingCows + milkingHeifers,
                cows: milkingCows,
                heifers: milkingHeifers,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatusItemCard(
                title: 'Сухостой',
                badgeColor: const Color(0xFF3E5BD8),
                badgeValue: dryCows + dryHeifers,
                cows: dryCows,
                heifers: dryHeifers,
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
                badgeValue: openCows + openHeifers,
                cows: openCows,
                heifers: openHeifers,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatusItemCard(
                title: 'Осемененные',
                badgeColor: Colors.teal,
                badgeValue: inseminatedCows + inseminatedHeifers,
                cows: inseminatedCows,
                heifers: inseminatedHeifers,
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
  final int cows;
  final int heifers;

  const _StatusItemCard({
    required this.title,
    required this.badgeColor,
    required this.badgeValue,
    required this.cows,
    required this.heifers,
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
            'Коровы: $cows',
            style: TextStyle(fontSize: 12, color: AppColors.primary3),
          ),
          Text(
            'Тёлки: $heifers',
            style: TextStyle(fontSize: 12, color: AppColors.primary3),
          ),
        ],
      ),
    );
  }
}

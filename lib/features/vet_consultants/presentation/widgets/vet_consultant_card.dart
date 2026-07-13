import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/features/vet_consultants/data/models/vet_consultant_dto.dart';

/// Карточка ветврача: фото/плейсхолдер, имя, специализация, описание,
/// цена консультации и кнопка перехода в WhatsApp.
class VetConsultantCard extends StatelessWidget {
  final VetConsultantDto consultant;

  /// Идёт фиксация обращения / открытие WhatsApp — блокируем повторные тапы.
  final bool busy;
  final VoidCallback onWhatsApp;

  const VetConsultantCard({
    super.key,
    required this.consultant,
    required this.busy,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final description = consultant.description;
    final price = consultant.consultationPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.additional2),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(213, 215, 218, 0.18),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(photoUrl: consultant.photoUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultant.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary3,
                        ),
                      ),
                      if (consultant.specialization.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          consultant.specialization,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.additional3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.additional3,
                ),
              ),
            ],
            if (price != null) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.additional2, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    l10n.vetConsultantPriceLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.additional3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTenge(price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.background3,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            FermerPlusBigButton(
              text: busy ? l10n.vetOpeningWhatsapp : l10n.supportWriteWhatsapp,
              height: 48,
              borderRadius: 24,
              onPressed: busy ? () {} : onWhatsApp,
            ),
          ],
        ),
      ),
    );
  }
}

/// Цена в тенге: целые — без дробной части.
String _formatTenge(double value) {
  if (value == value.roundToDouble()) return '${value.toInt()} ₸';
  final s = value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
  return '$s ₸';
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;

  const _Avatar({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary1.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: AppIcons.svg('user', size: 26, color: AppColors.primary1),
    );

    final url = photoUrl;
    if (url == null || url.isEmpty) return placeholder;

    return ClipOval(
      child: SizedBox(
        width: 56,
        height: 56,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : placeholder,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_outlined_button.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/finance_entities.dart';
import '../finance_format.dart';
import '../finance_styles.dart';
import 'finance_chips.dart';
import 'finance_common.dart';

/// Подпись над нестандартным полем (плитки, чипы) и ошибка под ним.
/// [note] — приглушённо справа от подписи: «можно пропустить».
class FinanceLabeled extends StatelessWidget {
  const FinanceLabeled({
    super.key,
    required this.label,
    required this.child,
    this.note,
    this.error,
  });

  final String label;
  final Widget child;
  final String? note;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary3,
            ),
            children: [
              if (note != null)
                TextSpan(
                  text: '  $note',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.additional3,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        child,
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

/// Счета чипами с остатком. С переносом, а не прокруткой: выбранный по
/// умолчанию счёт не должен прятаться за краем экрана.
class FinanceAccountChips extends StatelessWidget {
  const FinanceAccountChips({
    super.key,
    required this.accounts,
    required this.selectedId,
    required this.onSelected,
  });

  final List<FinanceAccount> accounts;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final format = FinanceFormat.of(context);
    return FinanceChipRow(
      wrap: true,
      children: [
        for (final account in accounts)
          FinanceChip(
            label: account.name,
            icon: account.type.iconName,
            trailingText: format.money(account.balance),
            selected: account.id == selectedId,
            onTap: () => onSelected(account.id),
          ),
      ],
    );
  }
}

/// Без счёта деньги не записать: объясняем и ведём к созданию.
class FinanceNoAccounts extends StatelessWidget {
  const FinanceNoAccounts({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FinanceCallout(
          text: l10n.financeNoActiveAccounts,
          tone: FinanceCalloutTone.info,
        ),
        const SizedBox(height: 10),
        AppOutlinedButton(
          text: l10n.financeAddAccount,
          height: 44,
          onPressed: () => context.push('/finance/accounts/new'),
        ),
      ],
    );
  }
}

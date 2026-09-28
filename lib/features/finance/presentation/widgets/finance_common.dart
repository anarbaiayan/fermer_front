import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';

import '../../domain/entities/finance_entities.dart';
import '../finance_format.dart';
import '../finance_styles.dart';

/// Иконка в скруглённом квадрате с прозрачной подложкой цвета иконки —
/// как пункты «Ещё».
class FinanceIconSquare extends StatelessWidget {
  const FinanceIconSquare({super.key, required this.icon, required this.color})
    : _size = 42,
      _iconSize = 22,
      _radius = 12;

  const FinanceIconSquare.small({
    super.key,
    required this.icon,
    required this.color,
  }) : _size = 36,
       _iconSize = 20,
       _radius = 10;

  /// Крупная — на экране первого входа.
  const FinanceIconSquare.large({
    super.key,
    required this.icon,
    required this.color,
  }) : _size = 64,
       _iconSize = 32,
       _radius = 20;

  final String icon;
  final Color color;
  final double _size;
  final double _iconSize;
  final double _radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: AppIcons.svg(icon, size: _iconSize, color: color),
    );
  }
}

enum FinancePillTone { paid, due, overdue, muted }

/// Маленькая цветная метка: статус продажи, «Новое», сумма долга.
class FinancePill extends StatelessWidget {
  const FinancePill({super.key, required this.label, required this.tone});

  final String label;
  final FinancePillTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      FinancePillTone.paid => (
        FinanceColors.paidBackground,
        FinanceColors.paidText,
      ),
      FinancePillTone.due => (
        FinanceColors.dueBackground,
        FinanceColors.dueText,
      ),
      FinancePillTone.overdue => (
        FinanceColors.overdueBackground,
        FinanceColors.overdueText,
      ),
      FinancePillTone.muted => (FinanceColors.fieldFill, AppColors.additional3),
    };
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      // По ширине текста, даже в растягивающей колонке.
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

/// Статус продажи: «Оплачено», «В долг до 24.09», «Просрочено 6 дн.».
class SaleStatusPill extends StatelessWidget {
  const SaleStatusPill({super.key, required this.sale, required this.today});

  final Sale sale;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (sale.statusOn(today)) {
      SaleStatus.paid => FinancePill(
        label: l10n.financeSaleStatusPaid,
        tone: FinancePillTone.paid,
      ),
      SaleStatus.overdue => FinancePill(
        label: l10n.financeSaleStatusOverdue(sale.overdueDaysOn(today)),
        tone: FinancePillTone.overdue,
      ),
      SaleStatus.due => FinancePill(
        label: sale.dueDate == null
            ? l10n.financeSaleStatusDebt
            : l10n.financeSaleStatusDue(
                FinanceFormat.of(context).dayMonth(sale.dueDate!),
              ),
        tone: FinancePillTone.due,
      ),
    };
  }
}

/// Плавающая кнопка «+ Продажа» / «+ Расход» на вкладках списков.
class FinanceAddButton extends StatelessWidget {
  const FinanceAddButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: onPressed,
      backgroundColor: AppColors.primary1,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const StadiumBorder(),
      icon: const Icon(Icons.add_rounded, size: 22),
      label: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Белая карточка с рамкой — основной контейнер списков «Финансов».
class FinanceCard extends StatelessWidget {
  const FinanceCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.color = Colors.white,
    this.borderColor = AppColors.additional2,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(213, 215, 218, 0.18),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Строка списка: иконка, название с подписью, сумма или метка справа.
class FinanceListRow extends StatelessWidget {
  const FinanceListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.footer,
    this.onTap,
    this.showChevron = false,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// Метка под подписью, например долг покупателя. Не отнимает ширину у
  /// названия, как [trailing].
  final Widget? footer;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: LayoutBuilder(builder: _buildRow),
      ),
    );
  }

  Widget _buildRow(BuildContext context, BoxConstraints constraints) {
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.additional3,
                  ),
                ),
              ],
              if (footer != null) ...[const SizedBox(height: 6), footer!],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          // Сумма или метка справа занимают не больше половины строки
          // и при нехватке места уменьшаются целиком, а не рвут ряд.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.55),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: trailing,
            ),
          ),
        ],
        if (showChevron) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.additional3,
          ),
        ],
      ],
    );
  }
}

/// Карточка со строками через разделитель.
class FinanceCardList extends StatelessWidget {
  const FinanceCardList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.additional2),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Сумма крупно, для проверки на глаз: «Сейчас на счёте 245 000 ₸».
class FinanceAmountBox extends StatelessWidget {
  const FinanceAmountBox({
    super.key,
    required this.label,
    required this.amount,
  });

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: FinanceColors.softGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.primary1),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary1,
            ),
          ),
        ],
      ),
    );
  }
}

enum FinanceCalloutTone { info, soft }

/// Пояснение с иконкой «i»: коричневое — важное, зелёное — справка.
class FinanceCallout extends StatelessWidget {
  const FinanceCallout({
    super.key,
    required this.text,
    this.tone = FinanceCalloutTone.soft,
  });

  final String text;
  final FinanceCalloutTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (tone) {
      FinanceCalloutTone.info => (
        FinanceColors.dueBackground,
        const Color(0xFF6B3A21),
        FinanceColors.dueText,
      ),
      FinanceCalloutTone.soft => (
        FinanceColors.softGreen,
        AppColors.primary1,
        AppColors.primary1,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: icon),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, height: 1.45, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Приглушённый текст под кнопкой: «Остаток «Касса» станет 474 000 ₸».
class FinanceNote extends StatelessWidget {
  const FinanceNote(this.text, {super.key, this.color = AppColors.additional3});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13, color: color),
    );
  }
}

/// Пустое состояние или ошибка внутри карточки. С [onRetry] показывает
/// кнопку «Повторить».
class FinanceMessageCard extends StatelessWidget {
  const FinanceMessageCard({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.onRetry,
  });

  /// Ошибка загрузки с сообщением бэкенда и повтором.
  factory FinanceMessageCard.error(
    BuildContext context, {
    Key? key,
    String? message,
    required VoidCallback onRetry,
  }) => FinanceMessageCard(
    key: key,
    title: context.l10n.financeLoadError,
    message: message,
    onRetry: onRetry,
  );

  final String title;
  final String? message;
  final Widget? icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(height: 10)],
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.additional3,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: onRetry,
              child: Text(
                context.l10n.financeRetry,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

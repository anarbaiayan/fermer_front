import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:frontend/features/pharmacy/application/pharmacy_providers.dart';
import 'package:frontend/features/pharmacy/data/models/create_vet_drug_request_dto.dart';
import 'package:frontend/features/pharmacy/data/models/drug_group_dto.dart';
import 'package:frontend/features/pharmacy/data/models/drug_offer_dto.dart';
import 'package:frontend/features/pharmacy/presentation/pharmacy_format.dart';
import 'package:frontend/features/pharmacy/presentation/widgets/drug_placeholder_image.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DrugGroupDetailsScreen extends ConsumerStatefulWidget {
  final DrugGroupDto group;

  const DrugGroupDetailsScreen({super.key, required this.group});

  @override
  ConsumerState<DrugGroupDetailsScreen> createState() =>
      _DrugGroupDetailsScreenState();
}

class _DrugGroupDetailsScreenState
    extends ConsumerState<DrugGroupDetailsScreen> {
  int _selectedOffer = 0;
  int _quantity = 1;

  DrugGroupDto get group => widget.group;

  DrugOfferDto? get _offer =>
      group.offers.isEmpty ? null : group.offers[_selectedOffer];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final offer = _offer;
    final total = offer?.price == null ? null : offer!.price! * _quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: group.title, onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  DrugPlaceholderImage(
                    imageUrl: offer?.imageUrl,
                    height: 210,
                    borderRadius: 16,
                    iconSize: 76,
                  ),
                  const SizedBox(height: 16),
                  _TagsRow(group: group),
                  const SizedBox(height: 10),
                  Text(
                    group.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary3,
                    ),
                  ),
                  if (offer != null && offer.name != group.title) ...[
                    const SizedBox(height: 6),
                    Text(
                      offer.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.additional3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  if (group.offers.isEmpty)
                    Text(
                      l10n.pharmacyNoOffers,
                      style: const TextStyle(color: AppColors.additional3),
                    )
                  else ...[
                    Text(
                      l10n.pharmacyPricesByProducer.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                        color: AppColors.additional3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (var i = 0; i < group.offers.length; i++)
                      _OfferRow(
                        offer: group.offers[i],
                        selected: i == _selectedOffer,
                        isCheapest: i == 0 && group.hasComparison,
                        selectable: group.offers.length > 1,
                        onTap: () => setState(() => _selectedOffer = i),
                      ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        l10n.pharmacyQuantity,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const Spacer(),
                      _QuantityStepper(
                        value: _quantity,
                        onChanged: (v) => setState(() => _quantity = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _BottomBar(
              totalLabel: l10n.pharmacyTotal,
              totalText: formatTenge(total),
              buttonText: l10n.pharmacyOrder,
              enabled: offer != null,
              onOrder: () => _openOrderSheet(offer!),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOrderSheet(DrugOfferDto offer) async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OrderSheet(drugId: offer.drugId, quantity: _quantity),
    );

    if (submitted != true || !mounted) return;

    await showAppSuccessDialog(
      context,
      title: context.l10n.pharmacyOrderSuccessTitle,
      message: context.l10n.pharmacyOrderSuccessMessage,
      buttonText: context.l10n.pharmacyOrderBackToCatalog,
      onButtonPressed: () {
        if (context.canPop()) context.pop();
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 20, 6),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: AppIcons.svg('arrow', size: 30),
            onPressed: onBack,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagsRow extends StatelessWidget {
  final DrugGroupDto group;

  const _TagsRow({required this.group});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tags = <String>[
      if ((group.actionName ?? '').isNotEmpty) group.actionName!,
      if (group.hasComparison)
        l10n.pharmacyOffers(group.offerCount)
      else if ((group.cheapestOffer?.companyName ?? '').isNotEmpty)
        group.cheapestOffer!.companyName,
    ];

    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final t in tags) _Tag(text: t)],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEBE4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.primary3,
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final DrugOfferDto offer;
  final bool selected;
  final bool isCheapest;
  final bool selectable;
  final VoidCallback onTap;

  const _OfferRow({
    required this.offer,
    required this.selected,
    required this.isCheapest,
    required this.selectable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final priceColor = isCheapest ? AppColors.background3 : AppColors.primary3;

    return InkWell(
      onTap: selectable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEFEDE6), width: 1),
          ),
        ),
        child: Row(
          children: [
            if (selectable)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? AppColors.primary1 : AppColors.additional2,
                ),
              ),
            Expanded(
              child: Text(
                offer.companyName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary3,
                ),
              ),
            ),
            if (isCheapest) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.background3.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.pharmacyBestPrice,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.background3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              formatTenge(offer.price),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: priceColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDEBE4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary3,
              ),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null ? AppColors.additional2 : AppColors.primary3,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String totalLabel;
  final String totalText;
  final String buttonText;
  final bool enabled;
  final VoidCallback onOrder;

  const _BottomBar({
    required this.totalLabel,
    required this.totalText,
    required this.buttonText,
    required this.enabled,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Color(0xFFEFEDE6))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  totalLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.additional3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary3,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppPrimaryButton(
                text: buttonText,
                onPressed: enabled ? onOrder : null,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Нижний лист оформления заказа. Адрес уходит в `comment`, телефон
/// предзаполняется из профиля и остаётся редактируемым (пустой допустим —
/// бэк подставит телефон из профиля).
class _OrderSheet extends ConsumerStatefulWidget {
  final int drugId;
  final int quantity;

  const _OrderSheet({required this.drugId, required this.quantity});

  @override
  ConsumerState<_OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends ConsumerState<_OrderSheet> {
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final phone = ref.read(authControllerProvider).user?.phoneNumber ?? '';
    _addressController = TextEditingController();
    _phoneController = TextEditingController(text: phone);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(createPharmacyRequestProvider)(
        CreateVetDrugRequestDto(
          drugId: widget.drugId,
          quantity: widget.quantity,
          comment: _addressController.text,
          contactPhone: _phoneController.text,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e is ApiException ? e.message : e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pharmacyOrderTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary3,
            ),
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: l10n.pharmacyOrderAddressLabel,
            hintText: l10n.pharmacyOrderAddressHint,
            controller: _addressController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.pharmacyOrderPhoneLabel,
            hintText: l10n.pharmacyOrderPhoneHint,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ],
          const SizedBox(height: 22),
          AppPrimaryButton(
            text: l10n.pharmacyOrderConfirm,
            onPressed: _submitting ? null : _submit,
            isLoading: _submitting,
          ),
        ],
      ),
    );
  }
}

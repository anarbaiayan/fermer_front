import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/pharmacy/application/pharmacy_providers.dart';
import 'package:frontend/features/pharmacy/data/models/vet_drug_request_dto.dart';
import 'package:frontend/features/pharmacy/presentation/pharmacy_format.dart';
import 'package:frontend/features/pharmacy/presentation/widgets/pharmacy_status_chip.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PharmacyRequestsScreen extends ConsumerWidget {
  const PharmacyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final requestsAsync = ref.watch(myPharmacyRequestsProvider);

    return AppScaffold(
      farmName: l10n.farmName,
      body: AppPage(
        child: Column(
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: AppIcons.svg('arrow', size: 32),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/pharmacy');
                    }
                  },
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.pharmacyRequestsTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: requestsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorState(
                  message: e is ApiException ? e.message : e.toString(),
                  onRetry: () => ref.invalidate(myPharmacyRequestsProvider),
                ),
                data: (requests) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(myPharmacyRequestsProvider);
                      await ref.read(myPharmacyRequestsProvider.future);
                    },
                    child: requests.isEmpty
                        ? const _EmptyRequests()
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 28),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: requests.length,
                            itemBuilder: (_, i) =>
                                _RequestCard(request: requests[i]),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final VetDrugRequestDto request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  request.drugName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PharmacyStatusChip(status: request.status),
            ],
          ),
          if ((request.companyName ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              request.companyName!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.additional3,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _MetaChip(
                icon: Icons.inventory_2_outlined,
                text: l10n.pharmacyQuantityShort(request.quantity),
              ),
              const SizedBox(width: 10),
              if (request.createdAt != null)
                _MetaChip(
                  icon: Icons.event_outlined,
                  text: formatRequestDate(request.createdAt),
                ),
            ],
          ),
          if ((request.contactPhone ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            _MetaLine(
              label: l10n.pharmacyRequestPhone,
              value: request.contactPhone!,
            ),
          ],
          if ((request.comment ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            _MetaLine(
              label: l10n.pharmacyRequestComment,
              value: request.comment!,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.additional3),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.primary3),
        ),
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  final String label;
  final String value;

  const _MetaLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: AppColors.primary3),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(color: AppColors.additional3),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 90),
        const Icon(
          Icons.receipt_long_outlined,
          size: 64,
          color: AppColors.additional2,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.pharmacyRequestsEmptyTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.pharmacyRequestsEmptySubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.additional3),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.errorPrefix(message),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primary3),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onRetry,
            child: Text(
              l10n.pharmacyRetry,
              style: const TextStyle(color: AppColors.primary1),
            ),
          ),
        ],
      ),
    );
  }
}

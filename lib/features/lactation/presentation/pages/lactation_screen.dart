import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/lactation/application/lactation_providers.dart';
import 'package:frontend/features/lactation/data/models/lactation_daily_summary_dto.dart';
import 'package:frontend/features/lactation/presentation/pages/lactation_milk_accounting_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final lactationRefreshingProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

class LactationScreen extends ConsumerWidget {
  const LactationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summaryAsync = ref.watch(lactationDailySummaryProvider);

    Future<void> refresh() async {
      if (ref.read(lactationRefreshingProvider)) return;

      ref.read(lactationRefreshingProvider.notifier).state = true;
      try {
        ref.invalidate(lactationDailySummaryProvider);
        ref.invalidate(lactationBulkListProvider);
        ref.invalidate(lactationBulkSummaryProvider);

        await Future.wait([
          ref.read(lactationDailySummaryProvider.future),
          ref.read(lactationBulkListProvider.future),
        ]);
      } finally {
        ref.read(lactationRefreshingProvider.notifier).state = false;
      }
    }

    String milkText(LactationDailySummaryDto s) {
      return l10n.lactationMilkPerDay(s.totalLiters.toStringAsFixed(0));
    }

    return AppScaffold(
      bottomNavIndex: 3,
      farmName: l10n.farmName,
      enableDrawer: true,
      showBell: true,
      showAppBar: true,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(12),
        child: FloatingActionButton(
          onPressed: () => context.push('/lactation/bulk/add'),
          backgroundColor: AppColors.primary1,
          elevation: 4,
          shape: const CircleBorder(),
          child: SizedBox(
            width: 63,
            height: 63,
            child: Center(
              child: AppIcons.svg('plus', size: 24, color: Colors.white),
            ),
          ),
        ),
      ),

      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 9),
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: AppIcons.svg('arrow', size: 32),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.lactationTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: AppIcons.svg('bell', size: 22),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: summaryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _LactationErrorState(
                  error: '$e',
                  onRetry: () => ref.invalidate(lactationDailySummaryProvider),
                ),
                data: (summary) {
                  final quantityLine = milkText(summary);

                  return Column(
                    children: [
                      _LactationQuantityCard(
                        subtitle: quantityLine,
                        onRefresh: refresh,
                      ),

                      const SizedBox(height: 12),

                      Expanded(child: const LactationMilkAccountingSection()),

                      // Expanded(
                      //   child: summaryAsync.when(
                      //     loading: () =>
                      //         const Center(child: CircularProgressIndicator()),
                      //     error: (e, _) => Center(
                      //       child: Text(
                      //         'Ошибка при загрузке: $e',
                      //         textAlign: TextAlign.center,
                      //         style: const TextStyle(
                      //           color: AppColors.additional3,
                      //         ),
                      //       ),
                      //     ),
                      //     data: (summary) {
                      //       final hasData = summary.totalLiters > 0; // или != 0

                      //       if (!hasData) {
                      //         return Column(
                      //           children: [
                      //             const Spacer(),
                      //             const _LactationEmptyState(),
                      //             const SizedBox(height: 20),
                      //             SizedBox(
                      //               width: double.infinity,
                      //               child: FermerPlusBigButton(
                      //                 text: 'Добавить надой за ферму',
                      //                 height: 50,
                      //                 onPressed: () =>
                      //                     context.push('/lactation/bulk/add'),
                      //               ),
                      //             ),
                      //             const Spacer(),
                      //           ],
                      //         );
                      //       }

                      //       return const LactationMilkAccountingSection();
                      //     },
                      //   ),
                      // ),
                    ],
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

class _LactationQuantityCard extends StatelessWidget {
  final String subtitle;
  final Future<void> Function() onRefresh;

  const _LactationQuantityCard({
    required this.subtitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Иконка слева - lactation_number.svg
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: AppIcons.svg('lactation_number', size: 30)),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.additional2, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.lactationQuantity,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async => onRefresh(),
                    child: AppIcons.svg('refresh', size: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class _LactationEmptyState extends StatelessWidget {
//   const _LactationEmptyState();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Image.asset(
//           'assets/image/noResult.png',
//           width: 180,
//           fit: BoxFit.contain,
//         ),
//         const SizedBox(height: 18),
//         const Text(
//           'Нет данных по надоям',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: AppColors.primary3,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           'Добавьте первый надой',
//           style: TextStyle(fontSize: 14, color: AppColors.additional3),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }

class _LactationErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _LactationErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.errorLoading,
            style: TextStyle(
              color: AppColors.primary3,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.additional3, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

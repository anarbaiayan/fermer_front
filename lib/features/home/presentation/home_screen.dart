import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/domain/entities/herd_filter.dart';
import 'package:frontend/features/home/presentation/widgets/briefSection/search_field.dart';
import 'package:frontend/features/home/presentation/widgets/quantitySection/summary_quantity_section.dart';
import 'package:frontend/features/pharmacy/presentation/widgets/pharmacy_home_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'widgets/briefSection/animal_status_card.dart';
import 'widgets/briefSection/herd_summary_card.dart';
import 'widgets/briefSection/summary_tabs.dart';

final herdLastUpdatedProvider = StateProvider<DateTime?>((ref) => null);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _summaryTabIndex = 0;

  String _formatTimeAgo(DateTime? time) {
    final l10n = context.l10n;
    if (time == null) return '—';

    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours == 1) return l10n.timeOneHourAgo;
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    return l10n.timeDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statsAsync = ref.watch(cattleStatisticsProvider);

    final lastUpdatedDt = ref.watch(herdLastUpdatedProvider);
    final lastUpdatedLabel = _formatTimeAgo(lastUpdatedDt);

    return AppScaffold(
      bottomNavIndex: 0,
      farmName: l10n.farmName,
      body: AppPage(
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              l10n.errorLoadingStats(err.toString()),
              textAlign: TextAlign.center,
            ),
          ),
          data: (stats) {
            final totalAnimals = stats.total;

            return ListView(
              children: [
                const SizedBox(height: 16),
                const SearchField(),
                const SizedBox(height: 16),
                const PharmacyHomeCard(),
                const SizedBox(height: 22),
                Text(
                  l10n.homeSummary,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SummaryTabs(
                  onTabChanged: (index) {
                    setState(() => _summaryTabIndex = index);
                  },
                ),
                const SizedBox(height: 16),
                if (_summaryTabIndex == 0) ...[
                  Text(
                    l10n.homeHerd,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  HerdSummaryCard(
                    totalAnimals: totalAnimals,
                    lastUpdated: lastUpdatedDt == null ? '—' : lastUpdatedLabel,
                    onRefresh: () {
                      ref.invalidate(cattleStatisticsProvider);
                      ref.read(herdLastUpdatedProvider.notifier).state =
                          DateTime.now();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.homeDataUpdating)),
                      );
                    },
                    onDetails: () {
                      context.go('/herd');
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.homeAnimalStatuses,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimalStatusCard(
                    lactating: stats.lactating,
                    dryPeriod: stats.dryPeriod,
                    open: stats.open,
                    inseminated: stats.inseminated,
                    onTap: (type) => context.push('/herd', extra: type),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.homeHerdHealth,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HealthStatusCard(
                          title: l10n.homeHealthy,
                          value: stats.healthy,
                          color: const Color(0xFF4AAE62),
                          onTap: () => context.push(
                            '/herd',
                            extra: HerdFilterType.healthy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HealthStatusCard(
                          title: l10n.homeSick,
                          value: stats.sick,
                          color: const Color(0xFFE10816),
                          onTap: () =>
                              context.push('/herd', extra: HerdFilterType.sick),
                        ),
                      ),
                    ],
                  ),
                ] else if (_summaryTabIndex == 1) ...[
                  const QuantitySummarySection(),
                ] else ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.homeTabNotImplemented(_summaryTabIndex + 1),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HealthStatusCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final VoidCallback? onTap;

  const _HealthStatusCard({
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: AppColors.additional2),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(213, 215, 218, 0.22),
                offset: Offset(0, 4),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      value.toString(),
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
                        color: AppColors.primary3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.herdTotalCount(value),
                style: const TextStyle(fontSize: 12, color: AppColors.primary3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/fermer_plus_app_bar.dart';
import 'package:frontend/features/home/presentation/widgets/briefSection/search_field.dart';
import 'package:frontend/features/home/presentation/widgets/quantitySection/summary_quantity_section.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/widgets/app_bottom_nav_bar.dart';
import 'widgets/briefSection/herd_summary_card.dart';
import 'widgets/briefSection/animal_status_card.dart';
import 'widgets/briefSection/summary_tabs.dart';
import '../../../features/auth/application/auth_providers.dart';

import 'package:frontend/features/herd/application/herd_providers.dart';

final herdLastUpdatedProvider = StateProvider<DateTime?>((ref) => null);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _summaryTabIndex = 0;

  // форматируем красивую надпись "X мин назад"
  String _formatTimeAgo(DateTime? time) {
    if (time == null) return '—';

    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours < 24) return '${diff.inHours} ч назад';
    return '${diff.inDays} д назад';
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(cattleStatisticsProvider);

    final lastUpdatedDt = ref.watch(herdLastUpdatedProvider);
    final lastUpdatedLabel = _formatTimeAgo(lastUpdatedDt);

    return Scaffold(
      appBar: const FermerPlusAppBar(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: AppPage(
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Ошибка при загрузке статистики:\n$err',
              textAlign: TextAlign.center,
            ),
          ),
          data: (stats) {
            final totalAnimals = stats.total;

            return ListView(
              children: [
                const SizedBox(height: 16),

                const SearchField(),

                const SizedBox(height: 22),
                const Text(
                  'Сводка',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                SummaryTabs(
                  onTabChanged: (index) {
                    setState(() => _summaryTabIndex = index);
                  },
                ),

                const SizedBox(height: 16),

                if (_summaryTabIndex == 0) ...[
                  const Text(
                    'Стадо',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  HerdSummaryCard(
                    totalAnimals: totalAnimals,
                    lastUpdated: lastUpdatedDt == null ? '—' : lastUpdatedLabel,
                    onRefresh: () {
                      ref.invalidate(cattleStatisticsProvider);

                      ref.read(herdLastUpdatedProvider.notifier).state =
                          DateTime.now();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Данные обновляются...')),
                      );
                    },
                    onDetails: () {
                      context.go('/herd');
                    },
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Статусы животных',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  AnimalStatusCard(
                    lactating: stats.lactating,
                    dryPeriod: stats.dryPeriod,
                    open: stats.open,
                    inseminated: stats.inseminated,
                  ),
                ] else if (_summaryTabIndex == 1) ...[
                  // тут позже подключим остальные поля статистики (cows/heifers/etc)
                  QuantitySummarySection(),
                ] else ...[
                  const SizedBox(height: 24),
                  Text(
                    'Контент для вкладки ${_summaryTabIndex + 1} ещё не реализован',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],

                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (context.mounted) context.go('/login');
                      },
                      child: const Text(
                        'Выйти',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

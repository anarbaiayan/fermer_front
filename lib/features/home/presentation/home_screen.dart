import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/home/presentation/widgets/briefSection/search_field.dart';
import 'package:frontend/features/home/presentation/widgets/quantitySection/summary_quantity_section.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'widgets/briefSection/herd_summary_card.dart';
import 'widgets/briefSection/animal_status_card.dart';
import 'widgets/briefSection/summary_tabs.dart';

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

    return AppScaffold(
      bottomNavIndex: 0,
      userName: 'Ахмет Кусаинов',
      farmName: 'Название фермы',
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
                    onTap: (type) => context.push('/herd', extra: type),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Здоровье стада',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _HealthStatusCard(
                          title: 'Здоровые',
                          value: stats.healthy,
                          color: const Color(0xFF4AAE62), // зелёный
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HealthStatusCard(
                          title: 'Больные',
                          value: stats.sick,
                          color: const Color(0xFFE10816), // красный
                        ),
                      ),
                    ],
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

  const _HealthStatusCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Всего: $value',
            style: const TextStyle(fontSize: 12, color: AppColors.primary3),
          ),
        ],
      ),
    );
  }
}

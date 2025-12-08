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

// новые импорты
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';

// ⬇ новый провайдер времени последнего обновления
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
    final herdAsync = ref.watch(cattleListProvider);

    // читаем последнее время обновления
    final lastUpdatedDt = ref.watch(herdLastUpdatedProvider);
    final lastUpdatedLabel = _formatTimeAgo(lastUpdatedDt);

    return Scaffold(
      appBar: const FermerPlusAppBar(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: AppPage(
        child: herdAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Ошибка при загрузке стада:\n$err',
              textAlign: TextAlign.center,
            ),
          ),
          data: (herd) {
            // ---- агрегируем статы по статусам ----
            int milkingCows = 0, milkingHeifers = 0;
            int dryCows = 0, dryHeifers = 0;
            int openCows = 0, openHeifers = 0;
            int inseminatedCows = 0, inseminatedHeifers = 0;

            for (final c in herd) {
              final resolved = AnimalCategoryResolver.resolve(
                gender: c.gender,
                dateOfBirth: c.dateOfBirth,
              );
              final category = resolved.category;
              final isCow = category == AnimalCategory.cow;
              final isHeifer = category == AnimalCategory.heifer;

              final d = c.details;

              final bool isDry = d?.isDryPeriod == true;
              final bool isMilking =
                  !isDry && (d?.lastMilkYield != null && d!.lastMilkYield! > 0);

              final String? preg = d?.pregnancyStatus;
              final bool isOpen = preg == 'NOT_PREGNANT';
              final bool isInseminated = preg == 'INSEMINATED';

              // дойные/сухостой
              if (isDry) {
                if (isCow) dryCows++;
                if (isHeifer) dryHeifers++;
              } else if (isMilking) {
                if (isCow) milkingCows++;
                if (isHeifer) milkingHeifers++;
              }

              // открытые/осемененные
              if (isOpen) {
                if (isCow) openCows++;
                if (isHeifer) openHeifers++;
              } else if (isInseminated) {
                if (isCow) inseminatedCows++;
                if (isHeifer) inseminatedHeifers++;
              }
            }

            final totalAnimals = herd.length;

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
                      // перезагрузить провайдер со стадом
                      ref.invalidate(cattleListProvider);

                      // сохранить новое время обновления
                      ref.read(herdLastUpdatedProvider.notifier).state =
                          DateTime.now();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Список обновляется...')),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Статусы животных',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  AnimalStatusCard(
                    milkingCows: milkingCows,
                    milkingHeifers: milkingHeifers,
                    dryCows: dryCows,
                    dryHeifers: dryHeifers,
                    openCows: openCows,
                    openHeifers: openHeifers,
                    inseminatedCows: inseminatedCows,
                    inseminatedHeifers: inseminatedHeifers,
                  ),
                ] else if (_summaryTabIndex == 1) ...[
                  QuantitySummarySection(),
                ] else ...[
                  const SizedBox(height: 24),
                  Text(
                    'Контент для вкладки ${_summaryTabIndex + 1} ещё не реализован',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],

                const SizedBox(height: 40),

                // временная кнопка "Выйти"
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

                        if (context.mounted) {
                          context.go('/login');
                        }
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

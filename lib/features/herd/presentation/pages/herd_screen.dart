import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/fermer_plus_app_bar.dart';
import 'package:frontend/core/widgets/app_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_list_item.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../widgets/herd_empty_state.dart';

class HerdScreen extends ConsumerWidget {
  const HerdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cattleListAsync = ref.watch(cattleListProvider);

    // показываем FAB только если список успешно загрузился и не пустой
    final hasCattle = cattleListAsync.maybeWhen(
      data: (cattle) => cattle.isNotEmpty,
      orElse: () => false,
    );

    final showFab = hasCattle;

    return Scaffold(
      appBar: const FermerPlusAppBar(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),

      floatingActionButton: showFab
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: FloatingActionButton(
                onPressed: () => context.push('/herd/add'),
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
            )
          : null,

      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 9),

            // Верхняя строка: стрелка + заголовок + иконки
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: AppIcons.svg('arrow', size: 32),
                  onPressed: () => context.go('/home'),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Весь скот',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
                const Spacer(),
                if (hasCattle) ...[
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: AppIcons.svg("search2", size: 20),
                    onPressed: () {
                      // TODO: поиск
                    },
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: AppIcons.svg("dots", size: 20),
                    onPressed: () {},
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: cattleListAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ошибка при загрузке списка',
                        style: TextStyle(
                          color: AppColors.primary3,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.additional3,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => ref.invalidate(cattleListProvider),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
                data: (cattle) {
                  if (cattle.isEmpty) {
                    return const HerdEmptyState();
                  }

                  return ListView(
                    children: [
                      _QuantityCard(
                        total: cattle.length,
                        onRefresh: () => ref.invalidate(cattleListProvider),
                      ),
                      const SizedBox(height: 15),
                      _HeaderWithFilter(),
                      const SizedBox(height: 15),
                      ..._buildCattleCards(context, cattle),
                      const SizedBox(height: 80),
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

  List<Widget> _buildCattleCards(BuildContext context, List<Cattle> cattle) {
    return [
      for (final item in cattle) ...[
        HerdListItem(
          cattle: item,
          onTap: () {
            context.push('/herd/${item.id}');
          },
        ),
        const SizedBox(height: 12),
      ],
    ];
  }
}

class _QuantityCard extends StatelessWidget {
  final int total;
  final VoidCallback onRefresh;

  const _QuantityCard({required this.total, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ---- Иконка слева (как в макете) ----
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: AppIcons.svg("health", size: 30)),
          ),

          const SizedBox(width: 16),

          // ---- Основная правая часть ----
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
                  // ---- Текст ----
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Количество',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Всего скота: $total',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---- Refresh icon ----
                  GestureDetector(
                    onTap: onRefresh,
                    child: AppIcons.svg("refresh", size: 13),
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

class _HeaderWithFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Список животных',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary3,
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          icon: AppIcons.svg("filter", size: 32),
          onPressed: () {
            // TODO: фильтры
          },
        ),
      ],
    );
  }
}

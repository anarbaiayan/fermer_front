import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';
import 'package:frontend/features/herd/domain/entities/herd_filter.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_list_item.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../widgets/herd_empty_state.dart';

final herdRefreshingProvider = StateProvider.autoDispose<bool>((ref) => false);

class HerdScreen extends ConsumerStatefulWidget {
  final HerdFilterType? filter;
  const HerdScreen({super.key, this.filter});

  @override
  ConsumerState<HerdScreen> createState() => _HerdScreenState();
}

class _HerdScreenState extends ConsumerState<HerdScreen> {
  final _searchController = TextEditingController();
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(activeHerdFilterProvider.notifier).state = widget.filter;
      ref.read(herdSearchQueryProvider.notifier).state = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cattleListAsync = ref.watch(cattleListProvider);
    final statsAsync = ref.watch(cattleStatisticsProvider);

    final hasCattle = cattleListAsync.maybeWhen(
      data: (cattle) => cattle.isNotEmpty,
      orElse: () => false,
    );

    return AppScaffold(
      bottomNavIndex: 1,
      farmName: l10n.farmName,
      enableDrawer: true,
      showBell: true,
      floatingActionButton: hasCattle
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 9),
            _SearchBar(
              isSearchMode: _isSearchMode,
              controller: _searchController,
              hasCattle: hasCattle,
              onSearchOpen: () => setState(() => _isSearchMode = true),
              onSearchClose: () {
                _searchController.clear();
                ref.read(herdSearchQueryProvider.notifier).state = '';
                setState(() => _isSearchMode = false);
              },
              onChanged: (v) =>
                  ref.read(herdSearchQueryProvider.notifier).state = v,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: cattleListAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _ErrorView(
                  error: err,
                  onRetry: () => ref.invalidate(cattleListProvider),
                ),
                data: (cattle) {
                  if (cattle.isEmpty) {
                    return const Center(child: HerdEmptyState());
                  }

                  final (:list, :isLoadingDetails) = ref.watch(
                    visibleCattleProvider,
                  );

                  // Детали ещё грузятся и список пока пуст
                  if (list.isEmpty && isLoadingDetails) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text(
                            l10n.herdLoadingFilter,
                            style: TextStyle(color: AppColors.additional3),
                          ),
                        ],
                      ),
                    );
                  }

                  if (list.isEmpty) {
                    return const Center(
                      child: HerdEmptyState(isSearchResult: true),
                    );
                  }

                  // Режим фильтра — просто грид
                  if (widget.filter != null) {
                    return _Grid(cattle: list);
                  }

                  // Обычный режим — с карточкой количества и заголовком
                  final total = statsAsync.maybeWhen(
                    data: (s) => s.total,
                    orElse: () => cattle.length,
                  );

                  Future<void> refresh() async {
                    if (ref.read(herdRefreshingProvider)) return;
                    ref.read(herdRefreshingProvider.notifier).state = true;
                    try {
                      ref.invalidate(cattleListProvider);
                      ref.invalidate(cattleStatisticsProvider);
                      for (final c in cattle) {
                        ref.invalidate(cattleDetailsProvider(c.id));
                        ref.invalidate(cattleByIdProvider(c.id));
                      }
                      await Future.wait([
                        ref.read(cattleListProvider.future),
                        ref.read(cattleStatisticsProvider.future),
                      ]);
                    } finally {
                      ref.read(herdRefreshingProvider.notifier).state = false;
                    }
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _QuantityCard(total: total, onRefresh: refresh),
                            const SizedBox(height: 15),
                            const _HeaderWithFilter(),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 80),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.62,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = list[index];
                            return HerdListItem(
                              cattle: item,
                              showHealth: true,
                              onTap: () => context.push('/herd/${item.id}'),
                            );
                          }, childCount: list.length),
                        ),
                      ),
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

// ─────────────────────────────────────────────
// Extracted widgets
// ─────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final bool isSearchMode;
  final bool hasCattle;
  final TextEditingController controller;
  final VoidCallback onSearchOpen;
  final VoidCallback onSearchClose;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.isSearchMode,
    required this.hasCattle,
    required this.controller,
    required this.onSearchOpen,
    required this.onSearchClose,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          icon: AppIcons.svg('arrow', size: 32),
          onPressed: () => context.go('/home'),
        ),
        const SizedBox(width: 4),
        if (!isSearchMode) ...[
          Text(
            l10n.herdAllCattle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary3,
            ),
          ),
          const Spacer(),
        ] else
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: l10n.searchByNameOrTag,
                border: InputBorder.none,
              ),
            ),
          ),
        if (hasCattle)
          isSearchMode
              ? IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close),
                  onPressed: onSearchClose,
                )
              : IconButton(
                  padding: EdgeInsets.zero,
                  icon: AppIcons.svg("search2", size: 20),
                  onPressed: onSearchOpen,
                ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.errorLoadingList,
            style: TextStyle(
              color: AppColors.primary3,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.additional3, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

class _QuantityCard extends StatelessWidget {
  final int total;
  final Future<void> Function() onRefresh;

  const _QuantityCard({required this.total, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
                        l10n.quantityTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.herdTotalCattle(total),
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
                  child: AppIcons.svg("refresh", size: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderWithFilter extends StatelessWidget {
  const _HeaderWithFilter();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.herdAnimalList,
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

class _Grid extends StatelessWidget {
  final List<Cattle> cattle;
  const _Grid({required this.cattle});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 80),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = cattle[index];
              return HerdListItem(
                cattle: item,
                showHealth: true,
                onTap: () => context.push('/herd/${item.id}'),
              );
            }, childCount: cattle.length),
          ),
        ),
      ],
    );
  }
}

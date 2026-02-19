import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/rations_providers.dart';
import '../../data/models/user_ration_dto.dart';

class UserRationsStocksScreen extends ConsumerWidget {
  final String? filterType;
  const UserRationsStocksScreen({super.key, this.filterType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stocksAsync = ref.watch(userRationsProvider);
    final title = filterType == null
        ? 'Запасы'
        : _typeTitle(filterType!);

    return AppScaffold(
      bottomNavIndex: 3,
      enableDrawer: true,
      showBell: true,
      showAppBar: true,
      farmName: 'Название фермы',
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 9),

            // верхняя строка
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: AppIcons.svg('arrow', size: 32),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
                const Spacer(),
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
                  onPressed: () {
                    // TODO: меню
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: stocksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Ошибка: $e', textAlign: TextAlign.center),
                ),
                data: (stocks) {
                  // если у тебя есть totalKg/totalT - подставь
                  final filtered = _applyFilter(stocks, filterType);
                  final totalText = 'Всего корма: ${_calcTotalKg(filtered)} кг';

                  return Stack(
                    children: [
                      CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                _QuantityCard(
                                  totalText: totalText,
                                  onRefresh: () async {
                                    ref.invalidate(userRationsProvider);
                                    await ref.read(userRationsProvider.future);
                                  },
                                ),
                                const SizedBox(height: 15),
                                const _HeaderWithFilter(),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),

                          SliverPadding(
                            padding: const EdgeInsets.only(bottom: 90),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final item = filtered[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: StockListItem(
                                    item: item,
                                    onDelete: () async {
                                      final del = ref.read(
                                        deleteUserRationProvider,
                                      );
                                      await del(item.id); // <- поле id
                                      ref.invalidate(userRationsProvider);

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Корм удалён'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              }, childCount: filtered.length),
                            ),
                          ),
                        ],
                      ),

                      // FAB "+"
                      // Positioned(
                      //   right: 14,
                      //   bottom: 24,
                      //   child: SizedBox(
                      //     width: 56,
                      //     height: 56,
                      //     child: FloatingActionButton(
                      //       backgroundColor: AppColors.primary1,
                      //       shape: const CircleBorder(),
                      //       onPressed: () =>
                      //           context.push('/rations/stocks/add'),
                      //       child: Center(
                      //         child: AppIcons.svg(
                      //           'plus',
                      //           size: 24,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ),
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

  List<UserRationDto> _applyFilter(List<UserRationDto> stocks, String? type) {
    if (type == null || type.trim().isEmpty) return stocks;
    final t = type.toUpperCase();
    return stocks.where((x) => (x.ration.type).toUpperCase() == t).toList();
  }

  String _typeTitle(String type) {
    switch (type.toUpperCase()) {
      case 'CONCENTRATED':
        return 'Концентраты';
      case 'JUICY':
        return 'Сочный корм';
      case 'COARSE':
        return 'Грубые корма';
      case 'ADDITIVE':
        return 'Добавки';
      default:
        return type;
    }
  }

  String _calcTotalKg(List<UserRationDto> items) {
    // подстрой под твои поля количества
    // например: item.quantityKg / item.remainingKg / item.amountKg
    double sum = 0;
    for (final x in items) {
      final v = (x.quantityKg); // <- ВАЖНО: поменяй на своё поле
      sum += v;
    }
    return sum.toStringAsFixed(0);
  }
}

class _QuantityCard extends StatelessWidget {
  final String totalText;
  final Future<void> Function() onRefresh;

  const _QuantityCard({required this.totalText, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // иконка слева - как на макете (коричневый квадрат)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFA55B2A), // коричневый как в макете
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: AppIcons.svg("health", size: 28, color: Colors.white),
            ),
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
                          totalText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary3,
                          ),
                        ),
                      ],
                    ),
                  ),
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
  const _HeaderWithFilter();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Список запасов',
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

class StockListItem extends StatefulWidget {
  final UserRationDto item;
  final Future<void> Function() onDelete;

  const StockListItem({super.key, required this.item, required this.onDelete});

  @override
  State<StockListItem> createState() => _StockListItemState();
}

class _StockListItemState extends State<StockListItem> {
  bool _showDelete = false;

  static const double _cardPad = 12;
  static const double _iconSize = 34;
  static const double _gap = 12;

  double get _contentLeft => _cardPad + _iconSize + _gap; // 58

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    final type = item.ration.type; // COARSE / JUICY / CONCENTRATED / ADDITIVE
    final color = _typeColor(type);

    final title = item.ration.name;
    final typeText = item.ration.typeDescription;
    final price = item.ration.pricePerKg;
    final qty = item.quantityKg;

    void toggle() => setState(() => _showDelete = !_showDelete);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: toggle,
      child: Container(
        padding: const EdgeInsets.all(_cardPad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(213, 215, 218, 0.22),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- top row (icon + title + edit) ---
            Row(
              children: [
                Container(
                  width: _iconSize,
                  height: _iconSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AppIcons.svg(
                    'inventory',
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18, // как на фото чуть крупнее
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary3,
                    ),
                  ),
                ),

                // круглая серая кнопка справа
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: toggle,
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    child: AppIcons.svg('change_icon', size: 25),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- divider starts after inventory icon ---
            Padding(
              padding: EdgeInsets.only(left: _contentLeft),
              child: const Divider(height: 1, color: AppColors.additional2),
            ),

            const SizedBox(height: 10),

            // --- all text block aligned after icon ---
            Padding(
              padding: EdgeInsets.only(left: _contentLeft),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Тип корма: $typeText',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Цена: ${price.toStringAsFixed(0)} ₸/кг',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Остаток: ${qty.toStringAsFixed(0)} кг',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primary3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_showDelete) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      barrierDismissible: true,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text(
                            'Удалить корм?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary3,
                            ),
                          ),
                          content: const Text(
                            'Вы уверены, что хотите удалить этот корм? Это действие нельзя отменить.',
                            style: TextStyle(color: AppColors.primary3),
                          ),
                          actionsPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text(
                                'Отмена',
                                style: TextStyle(color: AppColors.primary3),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Удалить'),
                            ),
                          ],
                        );
                      },
                    );

                    if (ok == true) {
                      await widget.onDelete();
                      if (mounted) setState(() => _showDelete = false);
                    }
                  },
                  child: const Text(
                    'Удалить корм',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _typeColor(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'CONCENTRATED':
      case 'CONCENTRATE':
        return const Color(0xFFB7E4C7); // cow green
      case 'JUICY':
        return const Color(0xFFF4C2C2); // heifer pink
      case 'COARSE':
        return const Color(0xFFF7DFA3); // calf yellow
      case 'ADDITIVE':
      default:
        return const Color(0xFF4A78C1); // bull blue
    }
  }
}

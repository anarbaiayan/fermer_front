import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/production_state.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/rations_providers.dart';
import '../../data/models/cattle_ration_dto.dart';

class CattleRationDetailsScreen extends ConsumerWidget {
  final int cattleId;
  const CattleRationDetailsScreen({super.key, required this.cattleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(cattleRationByCattleProvider(cattleId));

    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: true,
      showBell: false,
      showAppBar: true,
      farmName: 'Название фермы',
      backgroundColor: AppColors.primary1,
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Container(
          color: AppColors.background,
          child: AppPage(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Ошибка: $e', textAlign: TextAlign.center),
              ),
              data: (r) {
                final cat = AnimalCategoryX.fromApi(r.animalCategory ?? '');
                final prod = ProductionStateX.fromApi(r.productionState ?? '');

                final statusText = r.isOptimal
                    ? 'Активный'
                    : 'Требует внимания';
                final dailyKg = r.totalDailyKg.toStringAsFixed(0);

                final headerColor = _categoryColor(cat);

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: AppIcons.svg('arrow', size: 32),
                                  onPressed: () => context.pop(),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Информация о рационе',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 48),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: 1,
                                  color: AppColors.additional2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.04),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          headerColor.withOpacity(0.35),
                                          Colors.white,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      r.name ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary3,
                                      ),
                                    ),
                                  ),

                                  const Divider(
                                    height: 0.5,
                                    color: AppColors.additional2,
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.additional2,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          AppIcons.svg('info', size: 34),
                                          const SizedBox(width: 16),
                                          const Expanded(
                                            child: Text(
                                              'Основная информация рациона',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: Column(
                                      children: [
                                        _infoRow('Категория', cat.display),
                                        _infoRow('Период', prod.display),
                                        _infoRow('Статус', statusText),
                                        _infoRow('Норма в день', '$dailyKg кг'),
                                        if ((r.recommendations ?? '')
                                            .trim()
                                            .isNotEmpty)
                                          _infoRow(
                                            'Рекомендации',
                                            r.recommendations!.trim(),
                                          ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.additional2,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          AppIcons.svg(
                                            'inventory_card',
                                            size: 34,
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Кормы рациона',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      0,
                                      12,
                                      12,
                                    ),
                                    child: Column(
                                      children: r.items
                                          .map(
                                            (it) =>
                                                _CattleRationFeedTile(item: it),
                                          )
                                          .toList(),
                                    ),
                                  ),

                                  if ((r.warnings ?? '').trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        0,
                                        12,
                                        12,
                                      ),
                                      child: Text(
                                        r.warnings!.trim(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FermerPlusBigButton(
                        text: 'Закрыть',
                        height: 50,
                        borderRadius: 5,
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _categoryColor(AnimalCategory category) {
    switch (category) {
      case AnimalCategory.bull:
        return const Color(0xFF4A78C1);
      case AnimalCategory.calf:
        return const Color(0xFFF7DFA3);
      case AnimalCategory.cow:
        return const Color(0xFFB7E4C7);
      case AnimalCategory.heifer:
        return const Color(0xFFF4C2C2);
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim(),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CattleRationFeedTile extends StatefulWidget {
  final CattleRationItemDto item;
  const _CattleRationFeedTile({required this.item});

  @override
  State<_CattleRationFeedTile> createState() => _CattleRationFeedTileState();
}

class _CattleRationFeedTileState extends State<_CattleRationFeedTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final it = widget.item;

    final minKg = it.minKg.toStringAsFixed(2);
    final maxKg = it.maxKg.toStringAsFixed(2);
    final price = it.pricePerKg.toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.additional2),
        color: Colors.white,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _open = !_open),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      it.feedName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.primary3,
                  ),
                ],
              ),
            ),
          ),
          if (_open) ...[
            _FeedDetailRow(
              icon: AppIcons.svg('weight', size: 18),
              label: 'Мин (кг)',
              value: minKg,
            ),
            _FeedDetailRow(
              shaded: true,
              icon: AppIcons.svg('weight', size: 18),
              label: 'Макс (кг)',
              value: maxKg,
            ),
            _FeedDetailRow(
              icon: AppIcons.svg('money', size: 18),
              label: 'Цена (кг/тг)',
              value: price,
            ),
            if ((it.note ?? '').trim().isNotEmpty)
              _FeedDetailRow(
                shaded: true,
                icon: AppIcons.svg('info', size: 18),
                label: 'Заметка',
                value: it.note!.trim(),
              ),
          ],
        ],
      ),
    );
  }
}

class _FeedDetailRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final bool shaded;

  const _FeedDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.shaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: shaded ? const Color(0xFFF3F4F6) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary3,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

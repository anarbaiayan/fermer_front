import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/rations/presentation/widgets/cattle_ration_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/rations_providers.dart';

class RationsScreen extends ConsumerWidget {
  /// если передали cattleId - режим "из карточки животного"
  final int? cattleId;

  const RationsScreen({super.key, this.cattleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableAsync = ref.watch(userAvailableRationsProvider);

    // общий список
    final rationsAsync = ref.watch(cattleRationsProvider);

    // рацион конкретного животного
    final cattleRationAsync = (cattleId == null)
        ? const AsyncValue.data(null)
        : ref.watch(cattleRationByCattleProvider(cattleId!));

    final isFromCattle = cattleId != null;

    return AppScaffold(
      bottomNavIndex: 3,
      enableDrawer: true,
      showBell: true,
      showAppBar: true,
      farmName: 'Название фермы',
      body: AppPage(
        child: availableAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text('Ошибка: $e', textAlign: TextAlign.center)),
          data: (available) {
            if (available.isEmpty) {
              return _EmptyRationsState(
                onAdd: () => context.push('/rations/stocks/add'),
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const SizedBox(height: 10),

                // Заголовок разный:
                // - общий режим: "Список рационов" (как на скрине)
                // - из карточки: "Рацион животного"
                _Header(
                  title: isFromCattle ? 'Рацион животного' : 'Список рационов',
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  // фильтр только в общем режиме
                  trailing: isFromCattle
                      ? null
                      : IconButton(
                          padding: EdgeInsets.zero,
                          icon: AppIcons.svg("filter", size: 32),
                          onPressed: () {
                            // TODO: фильтры
                          },
                        ),
                ),

                const SizedBox(height: 18),

                // Запасы корма (оставляем как было)
                Row(
                  children: [
                    const Text(
                      'Запасы корма',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary3,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => context.push('/rations/stocks'),
                      child: const Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 92,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _StockTypeChip(
                        title: 'Концентраты',
                        color: const Color(0xFF4A78C1),
                        onTap: () =>
                            context.push('/rations/stocks/CONCENTRATED'),
                      ),
                      _StockTypeChip(
                        title: 'Сочный корм',
                        color: const Color(0xFFF7DFA3),
                        onTap: () => context.push('/rations/stocks/JUICY'),
                      ),
                      _StockTypeChip(
                        title: 'Грубые корма',
                        color: const Color(0xFFB7E4C7),
                        onTap: () => context.push('/rations/stocks/COARSE'),
                      ),
                      _StockTypeChip(
                        title: 'Добавки',
                        color: const Color(0xFFF4C2C2),
                        onTap: () => context.push(
                          '/rations/stocks/VITAMINS_SUPPLEMENTS',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ===== Секция рационов =====
                if (isFromCattle) ...[
                  // режим из карточки - показываем 1 рацион, кликабелен
                  cattleRationAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text('Ошибка: $e', textAlign: TextAlign.center),
                    ),
                    data: (ration) {
                      if (ration == null) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Center(
                            child: Text(
                              'Рацион ещё не сгенерирован',
                              style: TextStyle(color: AppColors.additional3),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CattleRationCard(
                          ration: ration,
                          variant: CattleRationCardVariant.fromCattle, // ✅
                          onTap: () =>
                              context.push('/rations/cattle/${cattleId!}'),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  // общий режим - список всех рационов, НЕ кликаются
                  rationsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text('Ошибка: $e', textAlign: TextAlign.center),
                    ),
                    data: (rations) {
                      if (rations.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Center(
                            child: Text(
                              'Рационы пока не сгенерированы',
                              style: TextStyle(color: AppColors.additional3),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          const SizedBox(height: 6),
                          ...rations.map((r) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CattleRationCard(
                                ration: r,
                                variant: CattleRationCardVariant.overview, // ✅
                                onTap: null, // ✅ запрет деталей в общем режиме
                                onDelete: () async {
                                  final del = ref.read(
                                    deleteCattleRationProvider,
                                  );
                                  await del(r.id);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Рацион удалён'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyRationsState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyRationsState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppPage(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/image/noResult.png', width: 260),
            const SizedBox(height: 24),
            const Text(
              'Ваш список пустует',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Для отображения списка рационов,\nдобавьте Ваш запас корма',
              style: TextStyle(fontSize: 14, color: AppColors.primary3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 55),
            SizedBox(
              width: double.infinity,
              child: FermerPlusBigButton(
                text: 'Добавить запасы корма',
                onPressed: onAdd,
                height: 50,
                borderRadius: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  const _Header({required this.title, required this.onBack, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          icon: AppIcons.svg('arrow', size: 32),
          onPressed: onBack,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary3,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StockTypeChip extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _StockTypeChip({required this.title, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 138,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.additional2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: AppIcons.svg('inventory', size: 18, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/production_state.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/rations_providers.dart';
import '../widgets/ration_template_card.dart';

class RationsScreen extends ConsumerWidget {
  final AnimalCategory? category;
  final ProductionState? productionState;
  const RationsScreen({super.key, this.category, this.productionState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableAsync = ref.watch(userAvailableRationsProvider);
    final templatesAsync = ref.watch(rationTemplatesProvider);

    return AppScaffold(
      bottomNavIndex: 3, // у тебя "Рационы" - 3
      enableDrawer: true,
      showBell: true,
      showAppBar: true,
      userName: 'Ахмет Кусаинов',
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

            // есть запасы -> показываем страницу как на скрине со списком рационов
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(bottom: 90),
                  children: [
                    const SizedBox(height: 10),
                    _Header(
                      title: 'Рационы/Запасы',
                      onBack: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                    ),
                    const SizedBox(height: 18),

                    // Запасы корма (минимальный блок - можешь расширить потом)
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
                            onTap: () =>
                                context.push('/rations/stocks/ADDITIVE'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        const Text(
                          'Список рационов',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary3,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: AppIcons.svg("filter", size: 32),
                          onPressed: () {
                            // TODO: фильтры
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    templatesAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text('Ошибка: $e', textAlign: TextAlign.center),
                      ),
                      data: (templates) {
                        if (templates.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: Center(
                              child: Text(
                                'Рационы пока не сгенерированы',
                                style: TextStyle(color: AppColors.additional3),
                              ),
                            ),
                          );
                        }

                        final filteredTemplates = templates.where((t) {
                          final templateCategory = AnimalCategoryX.fromApi(
                            t.animalCategory,
                          );
                          final templateProductionState =
                              ProductionStateX.fromApi(t.productionState);

                          final matchesCategory =
                              category == null || templateCategory == category;
                          final matchesState =
                              productionState == null ||
                              templateProductionState == productionState;

                          return matchesCategory && matchesState;
                        }).toList();

                        if (filteredTemplates.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: Center(
                              child: Text(
                                'Нет рационов, подходящих для этого животного',
                                style: TextStyle(color: AppColors.additional3),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            const SizedBox(height: 6),
                            ...filteredTemplates.map(
                              (t) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: RationTemplateCard(
                                  template: t,
                                  onTap: () => context.push(
                                    '/rations/templates/${t.id}',
                                  ),
                                  onDelete: () async {
                                    final del = ref.read(
                                      deleteRationTemplateProvider,
                                    );
                                    await del(t.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Рацион удалён'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                // FAB "+"
                Positioned(
                  right: 14,
                  bottom: 24,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xFF1F4E3B),
                      shape: const CircleBorder(),
                      onPressed: () {
                        context.push('/rations/generate');
                      },
                      child: Center(
                        child: AppIcons.svg(
                          'plus',
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
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

  const _Header({required this.title, required this.onBack});

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
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primary3,
          ),
        ),
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

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_animal_content.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HerdAnimalScreen extends ConsumerWidget {
  final int id;

  const HerdAnimalScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cattleAsync = ref.watch(cattleByIdProvider(id));

    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: true,
      showBell: true,
      farmName: 'Название фермы',
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Container(
          color: AppColors.background,
          child: AppPage(
            child: cattleAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ошибка при загрузке карточки',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.additional3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref.invalidate(cattleByIdProvider(id)),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
              data: (cattle) => HerdAnimalContent(
                cattle: cattle,
                onAddEvent: () {
                  context.push('/herd/${cattle.id}/events/add');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

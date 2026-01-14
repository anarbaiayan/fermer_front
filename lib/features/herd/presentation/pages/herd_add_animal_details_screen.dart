import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/features/cattle_events/presentation/pages/add_cattle_event_sheet.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_section_title.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_steps_indicator.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:frontend/features/herd/data/datasources/herd_api.dart';
import 'package:frontend/features/herd/data/models/cattle_details_dto.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';

class HerdAddAnimalDetailsScreen extends ConsumerStatefulWidget {
  final int cattleId;

  const HerdAddAnimalDetailsScreen({super.key, required this.cattleId});

  @override
  ConsumerState<HerdAddAnimalDetailsScreen> createState() =>
      _HerdAddAnimalDetailsScreenState();
}

class _HerdAddAnimalDetailsScreenState
    extends ConsumerState<HerdAddAnimalDetailsScreen> {
  final _eventCtrl = TextEditingController();
  final _milkYieldCtrl = TextEditingController();

  final _lastCalvingCtrl = TextEditingController();
  final _lastInseminationCtrl = TextEditingController();

  bool? _isPregnant;

  bool _saving = false;

  // final _dmy = DateFormat('dd.MM.yyyy');

  @override
  void dispose() {
    // _groupCtrl.dispose();
    _eventCtrl.dispose();
    _milkYieldCtrl.dispose();
    _lastCalvingCtrl.dispose();
    _lastInseminationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      final cattle = ref.read(cattleByIdProvider(widget.cattleId)).value;
      if (cattle == null) throw Exception('Данные животного не загружены');

      final resolved = AnimalCategoryResolver.resolve(
        gender: cattle.gender,
        dateOfBirth: cattle.dateOfBirth,
      );

      final isCowOrHeifer =
          resolved.category == AnimalCategory.cow ||
          resolved.category == AnimalCategory.heifer;

      final api = ref.read(herdApiProvider);

      if (isCowOrHeifer && _isPregnant != null) {
        final breed = cattle.details?.breed?.trim();

        if (breed == null || breed.isEmpty) {
          throw Exception(
            'Порода не указана - вернитесь на шаг 1 и заполните породу',
          );
        }

        await api.patchDetailsNoResponse(
          id: widget.cattleId,
          details: CattleDetailsDto(
            cattleCurrentState: _isPregnant == true ? 'PREGNANT' : 'OPEN',
          ),
        );

        ref.invalidate(cattleDetailsProvider(widget.cattleId));
        ref.invalidate(cattleByIdProvider(widget.cattleId));
        ref.invalidate(cattleListProvider);
      }

      if (!mounted) return;
      await showAppSuccessDialog(
        context,
        title: 'Карточка животного\nуспешно создана!',
        message:
            'Все данные сохранены.\nВы можете изменить их позже в карточке животного.',
        iconAsset: 'assets/icons/success.svg',
        buttonText: 'Понятно',
      );

      if (!mounted) return;
      context.go('/herd');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openAddEvent() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => AddCattleEventSheet(cattleId: widget.cattleId),
      backgroundColor: AppColors.background,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cattleAsync = ref.watch(cattleByIdProvider(widget.cattleId));

    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: false,
      showBell: false,
      showAppBar: true,
      backgroundColor: AppColors.primary1,
      userName: 'Ахмет Кусаинов',
      farmName: 'Название фермы',
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Container(
          color: AppColors.background,
          height: double.infinity,
          child: cattleAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Ошибка: $e')),
            data: (cattle) {
              // final resolved = AnimalCategoryResolver.resolve(
              //   gender: cattle.gender,
              //   dateOfBirth: cattle.dateOfBirth,
              // );
              // final isCowOrHeifer =
              //     resolved.category == AnimalCategory.cow ||
              //     resolved.category == AnimalCategory.heifer;

              return AppPage(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HerdPageHeader(
                        title: 'Добавление животного',
                        onBack: () => context.pop(),
                      ),
                      const SizedBox(height: 12),
                      const HerdStepsIndicator(currentStep: 2),
                      const SizedBox(height: 20),
                      const HerdSectionTitle(text: 'Дополнительная информация'),
                      const SizedBox(height: 24),

                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     const Text(
                      //       'Группа',
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w500,
                      //         color: AppColors.primary3,
                      //       ),
                      //     ),
                      //     const Spacer(),
                      //     SizedBox(
                      //       width: 265,
                      //       height: 36,
                      //       child: GestureDetector(
                      //         onTap: _saving
                      //             ? null
                      //             : () {
                      //                 // TODO: открыть выбор группы (sheet / dialog)
                      //               },
                      //         child: Container(
                      //           decoration: BoxDecoration(
                      //             color: Colors.white,
                      //             borderRadius: BorderRadius.circular(6),
                      //             border: Border.all(color: AppColors.primary1),
                      //           ),
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: [
                      //               Text(
                      //                 _groupCtrl.text.isEmpty
                      //                     ? 'Выбрать группу'
                      //                     : _groupCtrl.text,
                      //                 style: TextStyle(
                      //                   fontSize: 14,
                      //                   fontWeight: FontWeight.w500,
                      //                   color: _groupCtrl.text.isEmpty
                      //                       ? AppColors.primary1
                      //                       : AppColors.primary3,
                      //                 ),
                      //               ),
                      //               const SizedBox(width: 6),
                      //               AppIcons.svg(
                      //                 'arrow2',
                      //                 size: 14,
                      //                 color: AppColors.primary1,
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // // ),
                      // const SizedBox(height: 24),

                      // Действия
                      const Text(
                        'Действия',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        'Событие',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      HerdTextField(
                        controller: _eventCtrl,
                        readOnly: true,
                        hint: 'Добавить событие',
                        onTap: _saving ? null : _openAddEvent,
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 20,
                            color: AppColors.primary1,
                          ),
                          onPressed: _saving ? null : _openAddEvent,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _saving
                                  ? null
                                  : () => context.go('/herd'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: const Color.fromRGBO(
                                  213,
                                  215,
                                  218,
                                  0.6,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFF3F4F6),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                'Пропустить',
                                style: TextStyle(
                                  color: AppColors.additional3,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FermerPlusBigButton(
                              height: 50,
                              borderRadius: 5,
                              fontSize: 14,
                              text: _saving ? 'Сохранение...' : 'Сохранить',
                              onPressed: _saving ? () {} : _save,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

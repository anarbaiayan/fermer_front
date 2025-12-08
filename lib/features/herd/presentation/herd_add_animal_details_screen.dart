import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/fermer_plus_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:frontend/features/herd/domain/entities/health_status.dart';
import 'package:frontend/features/herd/data/datasources/herd_api.dart';
import 'package:frontend/features/herd/data/models/cattle_details_dto.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/domain/entities/cattle_create_data.dart';
import 'package:frontend/features/herd/data/models/cattle_mappers.dart';

class HerdAddAnimalDetailsScreen extends ConsumerStatefulWidget {
  final CattleCreateData draft;

  const HerdAddAnimalDetailsScreen({super.key, required this.draft});

  @override
  ConsumerState<HerdAddAnimalDetailsScreen> createState() =>
      _HerdAddAnimalDetailsScreenState();
}

class _HerdAddAnimalDetailsScreenState
    extends ConsumerState<HerdAddAnimalDetailsScreen> {
  final _breedController = TextEditingController();
  final _groupController = TextEditingController();
  final _eventController = TextEditingController();

  HealthStatus? _healthStatus;
  bool _isSaving = false;

  @override
  void dispose() {
    _breedController.dispose();
    _groupController.dispose();
    _eventController.dispose();
    super.dispose();
  }

  void _onSkip() async {
    final herdApi = ref.read(herdApiProvider);

    setState(() => _isSaving = true);

    try {
      final dto = cattleToDtoForCreate(
        name: widget.draft.name,
        tagNumber: widget.draft.tagNumber,
        gender: widget.draft.gender,
        dateOfBirth: widget.draft.dateOfBirth,
      );

      await herdApi.createCattle(dto);

      ref.invalidate(cattleListProvider);

      if (!mounted) return; // ⬅ проверка перед context
      await _showSuccessDialog(context);

      if (!mounted) return;
      context.go('/herd');
    } catch (e) {
      if (!mounted) return; // ⬅ проверка перед ScaffoldMessenger
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при создании животного: $e')),
      );
    } finally {
      if (!mounted) return; // ⬅ проверка перед setState
      setState(() => _isSaving = false);
    }
  }

  Future<void> _onSave() async {
    final herdApi = ref.read(herdApiProvider);

    setState(() => _isSaving = true);

    try {
      final baseDto = cattleToDtoForCreate(
        name: widget.draft.name,
        tagNumber: widget.draft.tagNumber,
        gender: widget.draft.gender,
        dateOfBirth: widget.draft.dateOfBirth,
      );

      final createdDto = await herdApi.createCattle(baseDto);
      final createdId = createdDto.id;
      if (createdId == null) {
        throw Exception('Сервер не вернул id животного');
      }

      final detailsDto = CattleDetailsDto(
        breed: _emptyToNull(_breedController.text),
        animalGroup: _emptyToNull(_groupController.text),
        healthStatus: _healthStatus?.apiValue,
      );

      await herdApi.updateDetails(id: createdId, details: detailsDto);

      ref.invalidate(cattleListProvider);

      if (!mounted) return;
      await _showSuccessDialog(context);

      if (!mounted) return;
      context.go('/herd');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении деталей: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/success.svg',
                  width: 50,
                  height: 50,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Карточка животного\nуспешно создана!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Список всех животных Вы найдете\nв разделе “Стадо”.\nРедактирование и добавление данных доступно\nвнутри карточки животного.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.authSmallText,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primary1,
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Понятно',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _emptyToNull(String text) {
    final value = text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary1,
      appBar: const FermerPlusAppBar(),
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: AppColors.background,
                child: AppPage(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: AppIcons.svg('arrow', size: 32),
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Добавление животного',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary3,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 48,
                            ), // симметрия под иконку слева
                          ],
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Дополнительная информация',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary3,
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Порода',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _breedController,
                          decoration: _inputDecoration(
                            hint: 'Введите название',
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ---- Левый текст ----
                            const Text(
                              'Группа',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary3,
                              ),
                            ),

                            const Spacer(),

                            // ---- Кнопка справа ----
                            SizedBox(
                              width: 265,
                              height: 36,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: выбор группы
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.primary1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // ⬅ центрируем!
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _groupController.text.isEmpty
                                            ? 'Выбрать группу  '
                                            : _groupController.text,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: _groupController.text.isEmpty
                                              ? AppColors.primary1
                                              : AppColors.primary3,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      AppIcons.svg(
                                        'arrow2',
                                        size: 14,
                                        color: AppColors.primary1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

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
                          'Состояние здоровья',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<HealthStatus>(
                          initialValue: _healthStatus,
                          decoration: _inputDecoration(
                            hint: 'Выбрать из списка',
                          ),
                          items: HealthStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.display),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _healthStatus = value;
                            });
                          },
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
                        TextField(
                          controller: _eventController,
                          decoration: _inputDecoration(
                            hint: 'Добавить событие',
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.add,
                                size: 20,
                                color: AppColors.primary1,
                              ),
                              onPressed: () {
                                // TODO: добавить событие в список
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSaving ? null : _onSkip,
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
                                text: _isSaving ? 'Сохранение...' : 'Сохранить',
                                onPressed: _isSaving ? () {} : _onSave,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.additional2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.additional2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.success, width: 1),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/data/datasources/herd_api.dart';
import 'package:frontend/features/herd/data/models/cattle_details_dto.dart';
import 'package:frontend/features/herd/data/models/cattle_mappers.dart';
import 'package:frontend/features/herd/domain/entities/breed_type.dart';
import 'package:frontend/features/herd/domain/entities/reproductive_state.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_gender_chip.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_section_title.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_steps_indicator.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_text_field.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:frontend/features/herd/domain/entities/cattle_gender.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

enum AnimalGender { female, male }

class HerdAddAnimalScreen extends ConsumerStatefulWidget {
  const HerdAddAnimalScreen({super.key});

  @override
  ConsumerState<HerdAddAnimalScreen> createState() =>
      _HerdAddAnimalScreenState();
}

class _HerdAddAnimalScreenState extends ConsumerState<HerdAddAnimalScreen> {
  final _nameController = TextEditingController();
  final _tagController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _breedController = TextEditingController();

  AnimalGender _gender = AnimalGender.female;
  DateTime? _birthDate;
  String? _categoryText;
  BreedType? _selectedBreedType;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _birthDateController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  CattleGender get _cattleGender =>
      _gender == AnimalGender.male ? CattleGender.male : CattleGender.female;

  Future<void> _openBirthDateDialog() async {
    final now = DateTime.now();
    final initialDate = _birthDate ?? now;

    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => _BirthDateDialog(initialDate: initialDate),
    );

    if (picked != null && mounted) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
      _recalculateCategory();
    }
  }

  void _onGenderChanged(AnimalGender gender) {
    setState(() {
      _gender = gender;
    });
    _recalculateCategory();
  }

  void _recalculateCategory() {
    if (_birthDate == null) {
      setState(() {
        _categoryText = null;
      });
      return;
    }

    final result = AnimalCategoryResolver.resolve(
      gender: _cattleGender,
      dateOfBirth: _birthDate!,
    );

    final category = result.category;
    final ageMonths = result.ageInMonths;

    setState(() {
      if (category == null) {
        _categoryText = 'Невозможно определить категорию';
      } else {
        _categoryText = 'Категория: ${category.display}, $ageMonths мес.';
      }
    });
  }

  Future<void> _onNext() async {
    final name = _nameController.text.trim();
    final tag = _tagController.text.trim();

    if (name.isEmpty || tag.isEmpty || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните имя, бирку и дату рождения')),
      );
      return;
    }

    final herdApi = ref.read(herdApiProvider);

    setState(() => _isLoading = true);

    try {
      final resolved = AnimalCategoryResolver.resolve(
        gender: _cattleGender,
        dateOfBirth: _birthDate!,
      );

      final category = resolved.category;
      final isCowOrHeifer =
          category == AnimalCategory.cow || category == AnimalCategory.heifer;

      final details = CattleDetailsDto(
        breed: _breedController.text.trim().isEmpty
            ? null
            : _breedController.text.trim(),
        breedType: _selectedBreedType?.apiValue,

        // ✅ ВАЖНО: репродуктивное состояние - только для коровы/телки
        cattleCurrentState: isCowOrHeifer
            ? ReproductiveState.open.apiValue
            : null,
      );

      final dto = cattleToDtoForCreate(
        name: name,
        tagNumber: tag,
        gender: _cattleGender,
        dateOfBirth: _birthDate!,
        details: details,
      );

      final created = await herdApi.createCattle(dto);

      final id = created.id;
      if (id == null) throw Exception('Сервер не вернул id животного');

      ref.invalidate(cattleListProvider);
      ref.invalidate(cattleStatisticsProvider); // чтобы “open”/total обновились

      if (!mounted) return;
      context.push('/herd/add/details', extra: id);
    } catch (e) {
      String message = 'Ошибка при создании животного';

      if (e is ApiException) {
        message = e.message;
      } else {
        message = e.toString();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: false,
      showBell: false,
      showAppBar: true,
      backgroundColor: AppColors.primary1,
      farmName: 'Название фермы',
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: Container(
                color: AppColors.background,
                child: AppPage(
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
                        const HerdStepsIndicator(currentStep: 1),
                        const SizedBox(height: 20),

                        const HerdSectionTitle(text: 'Основная информация'),

                        const SizedBox(height: 24),

                        const Text(
                          'Имя',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        HerdTextField(controller: _nameController),

                        const SizedBox(height: 24),

                        const Text(
                          'Бирка',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        HerdTextField(
                          controller: _tagController,
                          keyboardType: TextInputType.text,
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Выберите пол',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: HerdGenderChip(
                                label: 'Женский',
                                isActive: _gender == AnimalGender.female,
                                onTap: () =>
                                    _onGenderChanged(AnimalGender.female),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: HerdGenderChip(
                                label: 'Мужской',
                                isActive: _gender == AnimalGender.male,
                                onTap: () =>
                                    _onGenderChanged(AnimalGender.male),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Дата рождения',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary3,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 190,
                              child: HerdTextField(
                                controller: _birthDateController,
                                hint: '31.12.2020',
                                readOnly: true,
                                onTap: _openBirthDateDialog,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: AppIcons.svg(
                                    'calendar',
                                    size: 18,
                                    color: AppColors.primary3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

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
                        HerdTextField(
                          controller: _breedController,
                          hint: 'Введите породу',
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Тип породы',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<BreedType>(
                          value: _selectedBreedType,
                          decoration: InputDecoration(
                            hintText: 'Выберите тип породы',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9E9E9E),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: BreedType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setState(() => _selectedBreedType = v);
                          },
                        ),

                        if (_categoryText != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _categoryText!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.additional3,
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => context.pop(),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  side: const BorderSide(
                                    color: AppColors.additional2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  backgroundColor: const Color.fromRGBO(
                                    213,
                                    215,
                                    218,
                                    0.6,
                                  ),
                                ),
                                child: const Text(
                                  'Отменить',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FermerPlusBigButton(
                                fontSize: 14,
                                height: 50,
                                borderRadius: 24,
                                text: _isLoading ? 'Создание...' : 'Далее',
                                onPressed: _isLoading ? () {} : _onNext,
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
          ),
        ],
      ),
    );
  }
}

class _BirthDateDialog extends StatefulWidget {
  final DateTime initialDate;
  const _BirthDateDialog({required this.initialDate});

  @override
  State<_BirthDateDialog> createState() => _BirthDateDialogState();
}

class _BirthDateDialogState extends State<_BirthDateDialog> {
  bool inputMode = false;
  late DateTime selectedDate;
  late TextEditingController controller;

  final mask = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    controller = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(selectedDate),
    );
  }

  DateTime? _parse(String value) {
    try {
      return DateFormat('dd.MM.yyyy').parseStrict(value);
    } catch (_) {
      return null;
    }
  }

  bool _inRange(DateTime d) {
    final now = DateTime.now();
    final min = DateTime(now.year - 20, now.month, now.day);
    final max = DateTime(now.year, now.month, now.day);
    return !d.isBefore(min) && !d.isAfter(max);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 20, now.month, now.day);
    final lastDate = DateTime(now.year, now.month, now.day);

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      title: Row(
        children: [
          const Expanded(child: Text('Дата рождения')),
          IconButton(
            tooltip: inputMode ? 'Календарь' : 'Ввод',
            icon: Icon(inputMode ? Icons.calendar_today : Icons.edit),
            onPressed: () => setState(() => inputMode = !inputMode),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: inputMode
            ? TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [mask],
                decoration: const InputDecoration(hintText: 'ДД.ММ.ГГГГ'),
                onChanged: (v) {
                  if (mask.getUnmaskedText().length == 8) {
                    final parsed = _parse(v);
                    if (parsed != null && _inRange(parsed)) {
                      selectedDate = parsed;
                    }
                  }
                },
              )
            : CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: firstDate,
                lastDate: lastDate,
                onDateChanged: (d) {
                  selectedDate = d;
                  controller.text = DateFormat('dd.MM.yyyy').format(d);
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            if (inputMode) {
              final parsed = _parse(controller.text);
              if (parsed == null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Неверная дата')));
                return;
              }
              if (!_inRange(parsed)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Дата вне допустимого диапазона'),
                  ),
                );
                return;
              }
              selectedDate = parsed;
            }
            Navigator.pop(context, selectedDate);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

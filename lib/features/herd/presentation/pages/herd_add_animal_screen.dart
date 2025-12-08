import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/fermer_plus_app_bar.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_gender_chip.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_page_header.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_section_title.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_text_field.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:frontend/features/herd/domain/entities/cattle_gender.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:frontend/features/herd/domain/entities/cattle_create_data.dart';

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

  AnimalGender _gender = AnimalGender.female;
  DateTime? _birthDate;
  String? _categoryText;
  final bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  CattleGender get _cattleGender =>
      _gender == AnimalGender.male ? CattleGender.male : CattleGender.female;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
      helpText: 'Выберите дату рождения',
    );

    if (picked != null) {
      _birthDate = picked;
      _birthDateController.text = DateFormat('dd.MM.yyyy').format(picked);
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

    final draft = CattleCreateData(
      name: name,
      tagNumber: tag,
      gender: _cattleGender,
      dateOfBirth: _birthDate!,
    );

    context.push('/herd/add/details', extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary1,
      appBar: const FermerPlusAppBar(),
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
                                onTap: _pickDate,
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
                                    borderRadius: BorderRadius.circular(5),
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
                                borderRadius: 5,
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

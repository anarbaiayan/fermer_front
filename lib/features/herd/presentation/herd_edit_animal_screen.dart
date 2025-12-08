import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/fermer_plus_app_bar.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';
import 'package:frontend/features/herd/domain/entities/cattle_edit_data.dart';
import 'package:frontend/features/herd/domain/entities/cattle_gender.dart';
import 'package:frontend/features/herd/domain/entities/health_status.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum AnimalGender { female, male }

class HerdEditAnimalScreen extends ConsumerStatefulWidget {
  final Cattle cattle;

  const HerdEditAnimalScreen({super.key, required this.cattle});

  @override
  ConsumerState<HerdEditAnimalScreen> createState() =>
      _HerdEditAnimalScreenState();
}

class _HerdEditAnimalScreenState extends ConsumerState<HerdEditAnimalScreen> {
  final _nameController = TextEditingController();
  final _tagController = TextEditingController();
  final _birthDateController = TextEditingController();

  AnimalGender _gender = AnimalGender.female;
  DateTime? _birthDate;
  String? _categoryText;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final c = widget.cattle;

    _nameController.text = c.name;
    _tagController.text = c.tagNumber;
    _birthDate = c.dateOfBirth;
    _birthDateController.text = DateFormat('dd.MM.yyyy').format(c.dateOfBirth);
    _gender = c.gender == CattleGender.male
        ? AnimalGender.male
        : AnimalGender.female;

    _recalculateCategory();
  }

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
      initialDate: _birthDate ?? now,
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
      setState(() => _categoryText = null);
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

  HealthStatus? _mapHealthEnum(String? raw) {
    if (raw == null) return null;
    for (final status in HealthStatus.values) {
      if (status.apiValue == raw) return status;
    }
    return null;
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

    final details = widget.cattle.details;

    final draft = CattleEditData(
      id: widget.cattle.id,
      name: name,
      tagNumber: tag,
      gender: _cattleGender,
      dateOfBirth: _birthDate!,
      // то, что уже было:
      breed: details?.breed,
      animalGroup: details?.animalGroup,
      healthStatus: _mapHealthEnum(details?.healthStatus),
      // добавляем остальные, даже если пока не используем в форме
      lastMilkYield: details?.lastMilkYield,
      lastCalvingDate: details?.lastCalvingDate,
      lastInseminationDate: details?.lastInseminationDate,
      pregnancyStatus: details?.pregnancyStatus,
      isDryPeriod: details?.isDryPeriod,
    );

    context.push('/herd/edit/details', extra: draft);
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
                                'Редактирование карточки',
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
                          'Основная информация',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary3,
                          ),
                        ),

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
                        TextField(
                          controller: _nameController,
                          decoration: _inputDecoration(),
                        ),

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
                        TextField(
                          controller: _tagController,
                          decoration: _inputDecoration(),
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
                              child: _GenderChip(
                                label: 'Женский',
                                isActive: _gender == AnimalGender.female,
                                onTap: () =>
                                    _onGenderChanged(AnimalGender.female),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _GenderChip(
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
                              child: TextField(
                                controller: _birthDateController,
                                readOnly: true,
                                onTap: _pickDate,
                                decoration: _inputDecoration(
                                  hint: '31.12.2020',
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
                                text: _isLoading ? 'Сохранение...' : 'Далее',
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

  InputDecoration _inputDecoration({String? hint, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      prefixIcon: prefixIcon,
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

class _GenderChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isActive ? AppColors.primary1 : AppColors.additional2;
    final textColor = isActive ? Colors.white : AppColors.primary3;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

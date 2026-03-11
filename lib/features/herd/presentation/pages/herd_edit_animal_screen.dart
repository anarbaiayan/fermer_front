import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/masked_date_picker.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/data/datasources/herd_api.dart';
import 'package:frontend/features/herd/data/models/cattle_dto.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';
import 'package:frontend/features/herd/domain/entities/cattle_edit_data.dart';
import 'package:frontend/features/herd/domain/entities/cattle_gender.dart';
import 'package:frontend/features/herd/domain/entities/breed_type.dart';
import 'package:frontend/features/herd/domain/entities/health_status.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_gender_chip.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_section_title.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';

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
  BreedType? _selectedBreedType;

  bool _isLoading = false;

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

    _selectedBreedType = BreedTypeX.tryParse(c.details?.breedType);

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
    final picked = await showMaskedDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
      helpText: context.l10n.animalBirthDate,
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
      _recalculateCategory();
    }
  }

  void _onGenderChanged(AnimalGender gender) {
    setState(() => _gender = gender);
    _recalculateCategory();
  }

  void _recalculateCategory() {
    final l10n = context.l10n;
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
        _categoryText = l10n.animalCategoryUnknown;
      } else {
        _categoryText = l10n.animalCategoryWithAge(
          _categoryLabel(category, l10n),
          ageMonths,
        );
      }
    });
  }

  String _categoryLabel(AnimalCategory category, AppLocalizations l10n) {
    switch (category) {
      case AnimalCategory.cow:
        return l10n.rationCategoryCow;
      case AnimalCategory.heifer:
        return l10n.rationCategoryHeifer;
      case AnimalCategory.bull:
        return l10n.rationCategoryBull;
      case AnimalCategory.calf:
        return l10n.rationCategoryCalf;
    }
  }

  String _breedTypeLabel(BreedType type, AppLocalizations l10n) {
    switch (type) {
      case BreedType.DAIRY:
        return l10n.breedTypeDairy;
      case BreedType.MEAT:
        return l10n.breedTypeMeat;
      case BreedType.MIXED:
        return l10n.breedTypeMixed;
      case BreedType.LOCAL:
        return l10n.breedTypeLocal;
    }
  }

  HealthStatus? _mapHealthEnum(String? raw) {
    if (raw == null) return null;
    for (final status in HealthStatus.values) {
      if (status.apiValue == raw) return status;
    }
    return null;
  }

  Future<void> _onNext() async {
    final l10n = context.l10n;
    final herdApi = ref.read(herdApiProvider);

    final name = _nameController.text.trim();
    final tag = _tagController.text.trim();

    if (name.isEmpty || tag.isEmpty || _birthDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.animalRequiredFields)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ PUT /api/cattle/{id} - обновляем основную инфу
      final dto = CattleDto(
        id: widget.cattle.id,
        name: name,
        tagNumber: tag,
        gender: _cattleGender.apiValue,
        dateOfBirth: DateFormat('yyyy-MM-dd').format(_birthDate!),
        // важно: details не шлем в PUT основной инфы
        details: null,
      );

      await herdApi.updateCattleMain(id: widget.cattle.id, dto: dto);

      // (не обязательно, но полезно)
      ref.invalidate(cattleListProvider);
      ref.invalidate(cattleByIdProvider(widget.cattle.id));

      // draft для details экрана - берём то, что уже было в details
      final details = widget.cattle.details;

      final draft = CattleEditData(
        id: widget.cattle.id,
        name: name,
        tagNumber: tag,
        gender: _cattleGender,
        dateOfBirth: _birthDate!,
        breed: details?.breed,
        breedType: _selectedBreedType?.apiValue,
        animalGroup: details?.animalGroup,
        healthStatus: _mapHealthEnum(details?.healthStatus),
        lastMilkYield: details?.lastMilkYield,
        lastCalvingDate: details?.lastCalvingDate,
        lastInseminationDate: details?.lastInseminationDate,
        pregnancyStatus: details?.pregnancyStatus,
        isDryPeriod: details?.isDryPeriod,
      );

      if (!mounted) return;
      context.push('/herd/edit/details', extra: draft);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorPrefix('$e'))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: false,
      showBell: false,
      farmName: l10n.farmName,
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
                          title: l10n.animalInfoEditTitle,
                          onBack: () => context.pop(),
                        ),
                        const SizedBox(height: 12),
                        HerdSectionTitle(text: l10n.animalMainInfo),
                        const SizedBox(height: 24),

                        Text(
                          l10n.registerFirstName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        HerdTextField(controller: _nameController),

                        const SizedBox(height: 24),

                        Text(
                          l10n.animalTag,
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

                        Text(
                          l10n.selectGender,
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
                                label: l10n.genderFemale,
                                isActive: _gender == AnimalGender.female,
                                onTap: () =>
                                    _onGenderChanged(AnimalGender.female),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: HerdGenderChip(
                                label: l10n.genderMale,
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
                            Expanded(
                              child: Text(
                                l10n.animalBirthDate,
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

                        const SizedBox(height: 24),

                        Text(
                          l10n.breedTypeLabel,
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
                            hintText: l10n.breedTypeHint,
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
                              child: Text(_breedTypeLabel(type, l10n)),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setState(() => _selectedBreedType = v);
                          },
                        ),

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
                                child: Text(
                                  l10n.dialogCancel,
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
                                text: _isLoading
                                    ? l10n.saving
                                    : l10n.continueText,
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

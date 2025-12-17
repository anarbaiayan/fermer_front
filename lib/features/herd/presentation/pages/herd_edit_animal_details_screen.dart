import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/core/widgets/fermer_plus_app_bar.dart';
import 'package:frontend/features/cattle_events/presentation/pages/add_cattle_event_sheet.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/data/datasources/herd_api.dart';
import 'package:frontend/features/herd/data/models/cattle_details_dto.dart';
import 'package:frontend/features/herd/domain/entities/cattle_edit_data.dart';
import 'package:frontend/features/herd/domain/entities/health_status.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_section_title.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_text_field.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_input_decoration.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class HerdEditAnimalDetailsScreen extends ConsumerStatefulWidget {
  final CattleEditData draft;

  const HerdEditAnimalDetailsScreen({super.key, required this.draft});

  @override
  ConsumerState<HerdEditAnimalDetailsScreen> createState() =>
      _HerdEditAnimalDetailsScreenState();
}

class _HerdEditAnimalDetailsScreenState
    extends ConsumerState<HerdEditAnimalDetailsScreen> {
  late final TextEditingController _breedController;
  late final TextEditingController _groupController;
  final _eventController = TextEditingController();

  HealthStatus? _healthStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _breedController = TextEditingController(text: widget.draft.breed ?? '');
    _groupController = TextEditingController(
      text: widget.draft.animalGroup ?? '',
    );
    _healthStatus = widget.draft.healthStatus;
  }

  @override
  void dispose() {
    _breedController.dispose();
    _groupController.dispose();
    _eventController.dispose();
    super.dispose();
  }

  String? _emptyToNull(String text) {
    final value = text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _onSave() async {
    final herdApi = ref.read(herdApiProvider);

    setState(() => _isSaving = true);

    try {
      final detailsDto = CattleDetailsDto(
        breed: _emptyToNull(_breedController.text),
        animalGroup: _emptyToNull(_groupController.text),
        healthStatus: _healthStatus?.apiValue,
        lastMilkYield: widget.draft.lastMilkYield,
        lastCalvingDate: widget.draft.lastCalvingDate != null
            ? _formatDate(widget.draft.lastCalvingDate!)
            : null,
        lastInseminationDate: widget.draft.lastInseminationDate != null
            ? _formatDate(widget.draft.lastInseminationDate!)
            : null,
        pregnancyStatus: widget.draft.pregnancyStatus,
        isDryPeriod: widget.draft.isDryPeriod,
      );

      await herdApi.patchDetails(
        cattleId: widget.draft.id,
        details: detailsDto,
      );

      ref.invalidate(cattleListProvider);
      ref.invalidate(cattleByIdProvider(widget.draft.id));

      if (!mounted) return;

      await showAppSuccessDialog(
        context,
        title: 'Карточка животного\nуспешно обновлена!',
        iconAsset: 'assets/icons/success.svg',
        buttonText: 'Понятно',
        iconHeight: 50,
        iconWidth: 50,
      );
      if (!mounted) return;

      context.go('/herd');
    } catch (e, st) {
      debugPrint('UPDATE DETAILS error: $e\n$st');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении изменений: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _openAddEventSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: AddCattleEventSheet(cattleId: widget.draft.id),
        ),
      ),
    );
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
                        HerdPageHeader(
                          title: 'Редактирование карточки',
                          onBack: () => context.pop(),
                        ),

                        const SizedBox(height: 12),

                        const HerdSectionTitle(
                          text: 'Дополнительная информация',
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
                        HerdTextField(
                          controller: _breedController,
                          hint: 'Введите название',
                        ),

                        const SizedBox(height: 24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Группа',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary3,
                              ),
                            ),
                            const Spacer(),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                          decoration: herdInputDecoration(
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
                        HerdTextField(
                          controller: _eventController,
                          hint: 'Добавить событие',
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                              color: AppColors.primary1,
                            ),
                            onPressed: _openAddEventSheet,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => context.pop(),
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
}

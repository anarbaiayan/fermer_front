import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/features/cattle_events/presentation/pages/add_cattle_event_sheet.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/domain/entities/cattle_edit_data.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_section_title.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_text_field.dart';
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

  // группы пока убрали - оставляю контроллер, но UI и отправка закомментированы
  late final TextEditingController _groupController;

  final _eventController = TextEditingController();

  // cow/heifer extra
  final _milkYieldController = TextEditingController();
  final _lastCalvingCtrl = TextEditingController();
  final _lastInseminationCtrl = TextEditingController();

  DateTime? _lastCalvingDate;
  DateTime? _lastInseminationDate;

  bool _isSaving = false;
  final _dmy = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();

    _breedController = TextEditingController(text: widget.draft.breed ?? '');
    _groupController = TextEditingController(
      text: widget.draft.animalGroup ?? '',
    );

    _milkYieldController.text = widget.draft.lastMilkYield == null
        ? ''
        : widget.draft.lastMilkYield.toString();

    _lastCalvingDate = widget.draft.lastCalvingDate;
    _lastInseminationDate = widget.draft.lastInseminationDate;

    _lastCalvingCtrl.text = _lastCalvingDate == null
        ? ''
        : _dmy.format(_lastCalvingDate!);

    _lastInseminationCtrl.text = _lastInseminationDate == null
        ? ''
        : _dmy.format(_lastInseminationDate!);
  }

  @override
  void dispose() {
    _breedController.dispose();
    _groupController.dispose();
    _eventController.dispose();
    _milkYieldController.dispose();
    _lastCalvingCtrl.dispose();
    _lastInseminationCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    setState(() => _isSaving = true);
    try {
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
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: false,
      showBell: false,
      farmName: 'Название фермы',
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
                          readOnly: true,
                          hint: 'Добавить событие',
                          onTap: _isSaving ? null : _openAddEventSheet,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                              color: AppColors.primary1,
                            ),
                            onPressed: _isSaving ? null : _openAddEventSheet,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSaving
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

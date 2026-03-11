import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/core/widgets/masked_date_picker.dart';
import 'package:frontend/features/lactation/application/lactation_providers.dart';
import 'package:frontend/features/lactation/data/models/create_bulk_lactation_dto.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class AddBulkLactationScreen extends ConsumerStatefulWidget {
  const AddBulkLactationScreen({super.key});

  @override
  ConsumerState<AddBulkLactationScreen> createState() =>
      _AddBulkLactationScreenState();
}

class _AddBulkLactationScreenState
    extends ConsumerState<AddBulkLactationScreen> {
  final _dmy = DateFormat('dd.MM.yyyy');
  final _dateApi = DateFormat('yyyy-MM-dd');
  final _dtApi = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  final _dateCtrl = TextEditingController();
  final _cowsCtrl = TextEditingController();
  final _totalMilkCtrl = TextEditingController();
  final _calvesCtrl = TextEditingController();
  final _unsuitableCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 6, minute: 30); // дефолт утро

  DateTime _date = DateTime.now();
  String _milkingTime = 'MORNING'; // MORNING/EVENING
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = _dmy.format(_date);
    _applyDefaultTimeForMilkingTime(_milkingTime); // MORNING -> 06:30
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _cowsCtrl.dispose();
    _totalMilkCtrl.dispose();
    _calvesCtrl.dispose();
    _unsuitableCtrl.dispose();
    _notesCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final l10n = context.l10n;
    final picked = await showMaskedDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: l10n.lactationSelectDate,
    );

    if (picked == null) return;

    setState(() {
      _date = picked;
      _dateCtrl.text = _dmy.format(picked);
    });
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        final base = Theme.of(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: base.copyWith(
              colorScheme: base.colorScheme.copyWith(
                primary: AppColors.primary1,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _time = picked;
        _timeCtrl.text = _formatTime(picked);
      });
    }
  }

  void _applyDefaultTimeForMilkingTime(String milkingTime) {
    final t = milkingTime == 'MORNING'
        ? const TimeOfDay(hour: 6, minute: 30)
        : const TimeOfDay(hour: 18, minute: 30);

    _time = t;
    _timeCtrl.text = _formatTime(t);
  }

  DateTime _buildMilkingDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  int? _parseInt(String s) {
    final v = s.trim();
    return int.tryParse(v);
  }

  double? _parseDouble(String s) {
    final v = s.trim().replaceAll(',', '.');
    return double.tryParse(v);
  }

  double? _parseOptionalDouble(String s) {
    final v = s.trim();
    if (v.isEmpty) return null;
    return _parseDouble(v);
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final cows = _parseInt(_cowsCtrl.text);
    final total = _parseDouble(_totalMilkCtrl.text);

    if (cows == null || cows <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.lactationEnterCowCount)));
      return;
    }

    if (total == null || total <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.lactationEnterTotalMilk)));
      return;
    }

    final milkingDt = _buildMilkingDateTime(_date, _time);

    final dto = CreateBulkLactationDto(
      milkingDate: _dateApi.format(_date),
      milkingDateTime: _dtApi.format(milkingDt),
      milkingTime: _milkingTime,
      numberOfCows: cows,
      totalMilkLiters: total,
      milkUsedForCalves: _parseOptionalDouble(_calvesCtrl.text),
      unsuitableMilk: _parseOptionalDouble(_unsuitableCtrl.text),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    setState(() => _saving = true);
    try {
      final create = ref.read(createBulkLactationProvider);
      await create(dto);

      if (!mounted) return;

      await showAppSuccessDialog(
        context,
        title: l10n.lactationBulkSuccess,
        buttonText: l10n.lactationGoToList,
        onButtonPressed: () {
          context.go('/lactation');
        },
      );

      // если юзер закрыл диалог через кнопку - ок
      if (mounted) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorPrefix('$e'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _inputDecoration({String? hint, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: const Color.fromARGB(255, 95, 95, 95),
      ),
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      filled: true,
      fillColor: const Color.fromARGB(255, 239, 239, 239),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      bottomNavIndex: null,
      farmName: l10n.farmName,
      enableDrawer: false,
      showBell: false,
      backgroundColor: AppColors.primary1,
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Container(
          color: AppColors.background,
          child: AppPage(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bottomInset = MediaQuery.of(context).viewInsets.bottom;

                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),

                          // header: back + title
                          Row(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: AppIcons.svg('arrow', size: 32),
                                onPressed: () => context.pop(false),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.lactationFarmMilking,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _LabeledRightField(
                            label: l10n.lactationDate,
                            field: TextField(
                              controller: _dateCtrl,
                              readOnly: true,
                              onTap: _pickDate,
                              decoration: _inputDecoration(
                                hint: '31.12.',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 8,
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

                          const SizedBox(height: 16),

                          _LabeledRightField(
                            label: l10n.lactationTime,
                            field: TextField(
                              controller: _timeCtrl,
                              readOnly: true,
                              onTap: _pickTime,
                              decoration: _inputDecoration(
                                hint: '06:30',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: AppColors.primary3,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _Label(l10n.lactationMilkingTime),
                          const SizedBox(height: 6),
                          _DropdownField(
                            value: _milkingTime,
                            items: [
                              DropdownMenuItem(
                                value: 'MORNING',
                                child: Text(l10n.lactationMorning),
                              ),
                              DropdownMenuItem(
                                value: 'EVENING',
                                child: Text(l10n.lactationEvening),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() {
                                _milkingTime = v;
                                _applyDefaultTimeForMilkingTime(v);
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          _Label(l10n.lactationMilkedCows),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 48,
                            child: TextField(
                              controller: _cowsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                hint: l10n.lactationEnterCowCount,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _Label(l10n.lactationTotalMilk),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 48,
                            child: TextField(
                              controller: _totalMilkCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: _inputDecoration(
                                hint: l10n.lactationEnterMilk,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _Label(l10n.lactationCalfUsed),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 48,
                            child: TextField(
                              controller: _calvesCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: _inputDecoration(
                                hint: l10n.lactationEnterMilk,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _Label(l10n.lactationUnfitMilk),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 48,
                            child: TextField(
                              controller: _unsuitableCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: _inputDecoration(
                                hint: l10n.lactationEnterInfo,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE9ECEF,
                                        ),
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                      ),
                                      onPressed: _saving
                                          ? null
                                          : () => context.pop(false),
                                      child: Text(
                                        l10n.dialogCancel,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primary1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                      ),
                                      onPressed: _saving ? null : _submit,
                                      child: _saving
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              l10n.add,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primary3,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: const Color.fromARGB(255, 239, 239, 239),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _LabeledRightField extends StatelessWidget {
  final String label;
  final Widget field;

  const _LabeledRightField({required this.label, required this.field});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary3,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 220, child: field),
      ],
    );
  }
}

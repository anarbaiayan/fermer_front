import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/features/lactation/application/lactation_providers.dart';
import 'package:frontend/features/lactation/data/models/create_lactation_dto.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class AddLactationScreen extends ConsumerStatefulWidget {
  final int cattleId;
  final String cattleTagNumber;

  const AddLactationScreen({
    super.key,
    required this.cattleId,
    required this.cattleTagNumber,
  });

  @override
  ConsumerState<AddLactationScreen> createState() => _AddLactationScreenState();
}

class _AddLactationScreenState extends ConsumerState<AddLactationScreen> {
  final _milkCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _dmy = DateFormat('dd.MM.yyyy');
  final _dateCtrl = TextEditingController();
  final _dtApi = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  TimeOfDay _time = TimeOfDay.now();
  final _timeCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  String _milkingTime = 'MORNING'; // MORNING/EVENING
  bool _saving = false;

  final _dateFmtApi = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _tagCtrl.text = widget.cattleTagNumber;
    final now = DateTime.now();
    _date = now;
    _dateCtrl.text = _dmy.format(now);

    _time = TimeOfDay.fromDateTime(now);
    _timeCtrl.text = _formatTime(_time);
  }

  @override
  void dispose() {
    _milkCtrl.dispose();
    _tagCtrl.dispose();
    _notesCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary1),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _date = picked;
        _dateCtrl.text = _dmy.format(picked);
      });
    }
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary1),
          ),
          child: child!,
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

  DateTime _buildMilkingDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  double? _parseLiters(String s) {
    final v = s.trim().replaceAll(',', '.');
    return double.tryParse(v);
  }

  Future<void> _submit() async {
    final liters = _parseLiters(_milkCtrl.text);
    final milkingDt = _buildMilkingDateTime(_date, _time);
    if (liters == null || liters <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите количество молока (литры)')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final create = ref.read(createLactationProvider);

      final dto = CreateLactationDto(
        cattleId: widget.cattleId,
        milkingDate: _dateFmtApi.format(_date),
        milkingDateTime: _dtApi.format(milkingDt),
        milkingTime: _milkingTime,
        milkLiters: liters,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      await create(dto);

      if (!mounted) return;

      // попап как на дизайне, пока ведет в стадо
      await showAppSuccessDialog(
        context,
        title:
            'Информация успешно\nдобавлена и отображена\nв разделе “Лактация”',
        buttonText: 'Перейти к списку',
        onButtonPressed: () {
          context.go('/herd');
        },
      );

      // вернем true назад (на случай если пользователь закрыл попап)
      if (mounted) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavIndex: null,
      userName: 'Ахмет Кусаинов',
      farmName: 'Название фермы',
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),

                          // header как в макете: back + title
                          Row(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: AppIcons.svg('arrow', size: 32),
                                onPressed: () => context.pop(false),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Надой коровы',
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
                            label: 'Дата',
                            field: TextField(
                              controller: _dateCtrl,
                              readOnly: true,
                              onTap: _pickDate,
                              decoration: InputDecoration(
                                hintText: '31.12.2025',
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
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 42,
                                  minHeight: 42,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.additional2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.additional2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _LabeledRightField(
                            label: 'Время',
                            field: TextField(
                              controller: _timeCtrl,
                              readOnly: true,
                              onTap: _pickTime,
                              decoration: InputDecoration(
                                hintText: '06:30',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: AppColors.primary3,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 42,
                                  minHeight: 42,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.additional2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.additional2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _Label('Время доения'),
                          const SizedBox(height: 6),
                          _DropdownField(
                            value: _milkingTime,
                            items: const [
                              DropdownMenuItem(
                                value: 'MORNING',
                                child: Text('Утро'),
                              ),
                              DropdownMenuItem(
                                value: 'EVENING',
                                child: Text('Вечер'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _milkingTime = v);
                            },
                          ),

                          const SizedBox(height: 16),

                          _Label('Бирка коровы'),
                          const SizedBox(height: 6),
                          _TextField(
                            controller: _tagCtrl,
                            hint: 'Введите информацию',
                            enabled: false,
                          ),

                          const SizedBox(height: 16),

                          _Label('Количество молока'),
                          const SizedBox(height: 6),
                          _TextField(
                            controller: _milkCtrl,
                            hint: '',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
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
                                            6,
                                          ),
                                        ),
                                      ),
                                      onPressed: _saving
                                          ? null
                                          : () => context.pop(false),
                                      child: const Text(
                                        'Отменить',
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
                                            6,
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
                                          : const Text(
                                              'Добавить',
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.success),
        color: Colors.white,
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

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final TextInputType? keyboardType;

  const _TextField({
    required this.controller,
    required this.hint,
    this.enabled = true,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint.isEmpty ? null : hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.additional2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.additional2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.additional2),
          ),
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
        SizedBox(width: 170, child: field),
      ],
    );
  }
}

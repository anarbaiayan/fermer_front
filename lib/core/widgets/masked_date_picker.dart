import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/date_ddmmyyyy_formatter.dart';
import 'package:intl/intl.dart';

DateTime? tryParseDmy(String input) {
  if (input.length != 10) return null;
  final parts = input.split('.');
  if (parts.length != 3) return null;

  final dd = int.tryParse(parts[0]);
  final mm = int.tryParse(parts[1]);
  final yyyy = int.tryParse(parts[2]);
  if (dd == null || mm == null || yyyy == null) return null;

  final d = DateTime(yyyy, mm, dd);
  if (d.year != yyyy || d.month != mm || d.day != dd) return null;
  return d;
}

Future<DateTime?> showMaskedDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String helpText = 'Выберите дату',
}) {
  return showDialog<DateTime?>(
    context: context,
    builder: (_) => _MaskedDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
    ),
  );
}

class _MaskedDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String helpText;

  const _MaskedDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.helpText,
  });

  @override
  State<_MaskedDatePickerDialog> createState() =>
      _MaskedDatePickerDialogState();
}

class _MaskedDatePickerDialogState extends State<_MaskedDatePickerDialog> {
  final _dmy = DateFormat('dd.MM.yyyy');

  late DateTime _selected;
  bool _inputMode = false;

  late final TextEditingController _ctrl;

  String? _errorText;
  bool _okEnabled = true;

  @override
  void initState() {
    super.initState();
    _selected = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _ctrl = TextEditingController(text: _dmy.format(_selected));
    _validateText();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _inRange(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    final a = DateTime(
      widget.firstDate.year,
      widget.firstDate.month,
      widget.firstDate.day,
    );
    final b = DateTime(
      widget.lastDate.year,
      widget.lastDate.month,
      widget.lastDate.day,
    );
    return !x.isBefore(a) && !x.isAfter(b);
  }

  void _applyTextIfValid({bool showError = false}) {
    final text = _ctrl.text.trim();

    // если не полный ввод - просто не применяем
    if (text.length != 10) {
      if (showError) {
        setState(() {
          _errorText = 'Введите дату полностью';
          _okEnabled = false;
        });
      }
      return;
    }

    final parsed = tryParseDmy(text);
    if (parsed == null) {
      if (showError) {
        setState(() {
          _errorText = 'Неверная дата';
          _okEnabled = false;
        });
      }
      return;
    }

    if (!_inRange(parsed)) {
      if (showError) {
        final a = _dmy.format(widget.firstDate);
        final b = _dmy.format(widget.lastDate);
        setState(() {
          _errorText = 'Дата должна быть в диапазоне $a - $b';
          _okEnabled = false;
        });
      }
      return;
    }

    setState(() {
      _selected = parsed;
      _errorText = null;
      _okEnabled = true;
    });
  }

  void _validateText() {
    final text = _ctrl.text.trim();

    // пока не ввели 10 символов - не ругаемся и не блокируем жестко
    if (text.isEmpty || text.length < 10) {
      setState(() {
        _errorText = null;
        _okEnabled = false; // можно true, но лучше false чтобы не принять мусор
      });
      return;
    }

    final parsed = tryParseDmy(text);
    if (parsed == null) {
      setState(() {
        _errorText = 'Неверная дата';
        _okEnabled = false;
      });
      return;
    }

    if (!_inRange(parsed)) {
      final a = _dmy.format(widget.firstDate);
      final b = _dmy.format(widget.lastDate);
      setState(() {
        _errorText = 'Дата должна быть в диапазоне $a - $b';
        _okEnabled = false;
      });
      return;
    }

    setState(() {
      _errorText = null;
      _okEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.helpText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _inputMode = !_inputMode);
              // после переключения сразу проверим текст
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _validateText(),
              );
            },
            icon: Icon(_inputMode ? Icons.calendar_today : Icons.edit),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_inputMode) ...[
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                inputFormatters: const [DateDdMmYyyyInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Введите дату',
                  hintText: 'dd.MM.yyyy',
                  errorText: _errorText,
                ),
                onChanged: (_) {
                  _validateText();
                  // можно ещё синхронизировать календарь с корректным вводом
                  _applyTextIfValid();
                },
              ),
            ] else ...[
              CalendarDatePicker(
                initialDate: _selected,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onDateChanged: (d) {
                  setState(() {
                    _selected = d;
                    _ctrl.text = _dmy.format(d);
                    _errorText = null;
                    _okEnabled = true;
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: _okEnabled
              ? () {
                  _applyTextIfValid(showError: true);
                  if (!_okEnabled) return;
                  Navigator.of(context).pop(_selected);
                }
              : null,
          child: const Text('OK'),
        ),
      ],
    );
  }
}

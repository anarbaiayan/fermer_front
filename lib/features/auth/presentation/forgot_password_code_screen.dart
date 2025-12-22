import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class ForgotPasswordCodeScreen extends StatefulWidget {
  final String? phoneNumber;
  const ForgotPasswordCodeScreen({super.key, this.phoneNumber});

  @override
  State<ForgotPasswordCodeScreen> createState() =>
      _ForgotPasswordCodeScreenState();
}

class _ForgotPasswordCodeScreenState extends State<ForgotPasswordCodeScreen> {
  final _c = List.generate(4, (_) => TextEditingController());
  final _f = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final x in _c) {
      x.dispose();
    }
    for (final x in _f) {
      x.dispose();
    }
    super.dispose();
  }

  String get _code => _c.map((e) => e.text).join();

  void _applyPasted(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return;

    for (var i = 0; i < 4; i++) {
      _c[i].text = digits[i];
    }
    setState(() {});
    FocusScope.of(context).unfocus();
  }

  void _onChanged(int i, String v) {
    if (v.isEmpty) return;

    // если вставили сразу много символов (бывает на некоторых клавиатурах)
    if (v.length > 1) {
      _applyPasted(v);
      return;
    }

    if (i < 3) {
      _f[i + 1].requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
    setState(() {});
  }

  KeyEventResult _onKey(int i, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;

    // backspace - перейти назад, если текущее пустое
    if (e.logicalKey == LogicalKeyboardKey.backspace) {
      if (_c[i].text.isEmpty && i > 0) {
        _f[i - 1].requestFocus();
        _c[i - 1].selection = TextSelection.fromPosition(
          TextPosition(offset: _c[i - 1].text.length),
        );
        setState(() {});
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFCBD5E1); // как на макете
    const dotColor = Color(0xFF6B7280); // цвет точек

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppPage(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
            children: [
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'FERMER +',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary1,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Код верификации',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Введите 4-значный код верификации для сброса пароля',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.additional3,
                ),
              ),

              const SizedBox(height: 32),

              // OTP row - строго по центру
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (i) {
                    return Padding(
                      padding: EdgeInsets.only(right: i == 3 ? 0 : 14),
                      child: SizedBox(
                        width: 50,
                        height: 56,
                        child: KeyboardListener(
                          focusNode: FocusNode(),
                          onKeyEvent: (e) => _onKey(i, e),
                          child: TextField(
                            controller: _c[i],
                            focusNode: _f[i],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            showCursor: false,
                            enableInteractiveSelection: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            obscureText: true,
                            obscuringCharacter: '●',
                            style: const TextStyle(
                              fontSize: 30, // размер точки
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                              color: dotColor,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: borderColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: borderColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            onChanged: (v) => _onChanged(i, v),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 32),

              FermerPlusBigButton(
                text: 'Сбросить пароль',
                height: 50,
                borderRadius: 6,
                onPressed: () {
                  context.push(
                    '/forgot-password/new',
                    extra: {'code': _code, 'phone': widget.phoneNumber},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

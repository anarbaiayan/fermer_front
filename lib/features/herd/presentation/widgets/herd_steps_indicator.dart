import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HerdStepsIndicator extends StatelessWidget {
  final int currentStep; // 1 или 2

  /// Чтобы ширина совпала с инпутами (обычно 24 в твоих экранах)
  final double horizontalPadding;

  const HerdStepsIndicator({
    super.key,
    required this.currentStep,
    this.horizontalPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isStep1 = currentStep == 1;
    final isStep2 = currentStep == 2;

    const double circleSize = 20;
    const double lineHeight = 1;
    const double labelGap = 3;

    const double stepWidth = 64;
    const double gapFromCircle = 1;

    final step1State = isStep1 ? _StepState.icon : _StepState.done;
    final step2State = isStep2 ? _StepState.icon : _StepState.empty;

    final leftLineColor = (isStep1 || isStep2)
        ? AppColors.primary1
        : AppColors.additional2;
    final rightLineColor = isStep2 ? AppColors.primary1 : AppColors.additional2;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: stepWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepCircle(size: circleSize, state: step1State),
                const SizedBox(height: labelGap),
                const Text(
                  'Шаг 1',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.additional3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: circleSize / 2 - lineHeight / 2),
              child: Row(
                children: [
                  const SizedBox(width: gapFromCircle),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: lineHeight,
                            color: leftLineColor,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: lineHeight,
                            color: rightLineColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: gapFromCircle),
                ],
              ),
            ),
          ),

          SizedBox(
            width: stepWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepCircle(size: circleSize, state: step2State),
                const SizedBox(height: labelGap),
                const Text(
                  'Шаг 2',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.additional3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState { empty, icon, done }

class _StepCircle extends StatelessWidget {
  final _StepState state;
  final double size;

  const _StepCircle({required this.state, required this.size});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _StepState.done:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary1,
            border: Border.all(color: AppColors.primary1, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.check, size: 14, color: Colors.white),
          ),
        );

      case _StepState.icon:
        return SizedBox(
          width: size,
          height: size,
          child: Center(child: AppIcons.svg('step', size: size)),
        );

      case _StepState.empty:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.additional2, width: 1),
          ),
        );
    }
  }
}

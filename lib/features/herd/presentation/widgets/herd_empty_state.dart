import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class HerdEmptyState extends StatelessWidget {
  const HerdEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppPage(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/image/noResult.png',
              width: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 25),
            const Text(
              'Ваш список пустует',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Добавьте первую карточку своего животного',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 55),
            SizedBox(
              width: double.infinity,
              child: FermerPlusBigButton(
                text: 'Добавить животное',
                onPressed: () {
                  context.push('/herd/add'); // новый маршрут
                },
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

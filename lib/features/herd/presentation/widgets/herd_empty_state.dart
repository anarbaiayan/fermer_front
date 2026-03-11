import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class HerdEmptyState extends StatelessWidget {
  final bool isSearchResult; // ← добавить параметр
  const HerdEmptyState({super.key, this.isSearchResult = false});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/image/noResult.png',
              width: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 25),
            Text(
              isSearchResult ? l10n.emptySearchTitle : l10n.emptyHerdTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isSearchResult
                  ? l10n.emptySearchSubtitle
                  : l10n.emptyHerdSubtitle,
              style: const TextStyle(fontSize: 14, color: AppColors.primary3),
              textAlign: TextAlign.center,
            ),
            if (!isSearchResult) ...[
              const SizedBox(height: 55),
              SizedBox(
                width: double.infinity,
                child: FermerPlusBigButton(
                  text: l10n.addAnimal,
                  onPressed: () => context.push('/herd/add'),
                  height: 50,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

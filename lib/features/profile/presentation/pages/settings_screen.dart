import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/localization/locale_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(appLocaleProvider);
    final selected = _languageFromLocale(locale);

    return AppScaffold(
      farmName: l10n.farmName,
      showBell: false,
      body: AppPage(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  HerdPageHeader(
                    title: l10n.drawerSettings,
                    onBack: () => context.pop(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.additional2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(213, 215, 218, 0.22),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                          child: Text(
                            l10n.settingsLanguageTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary3,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                          child: Text(
                            l10n.settingsLanguageSubtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.additional3,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                          child: SegmentedButton<AppLanguage>(
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              foregroundColor: AppColors.primary3,
                              selectedForegroundColor: Colors.white,
                              selectedBackgroundColor: AppColors.primary1,
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            segments: [
                              ButtonSegment<AppLanguage>(
                                value: AppLanguage.ru,
                                label: Text(l10n.settingsLanguageRu),
                              ),
                              ButtonSegment<AppLanguage>(
                                value: AppLanguage.kk,
                                label: Text(l10n.settingsLanguageKk),
                              ),
                            ],
                            selected: {selected},
                            onSelectionChanged: (selectedValues) async {
                              final language = selectedValues.first;
                              await ref
                                  .read(appLocaleProvider.notifier)
                                  .setLanguage(language);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: FermerPlusBigButton(
                text: l10n.dialogClose,
                height: 50,
                borderRadius: 5,
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppLanguage _languageFromLocale(Locale locale) {
    return locale.languageCode == 'kk' ? AppLanguage.kk : AppLanguage.ru;
  }
}

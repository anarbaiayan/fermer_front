import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _phoneRaw = '77064078385';
  static const _phoneDisplay = '+7 706 407 83 85';

  Future<void> _openWhatsApp(BuildContext context) async {
    final l10n = context.l10n;

    final appUri = Uri.parse('whatsapp://send?phone=$_phoneRaw');
    final webUri = Uri.parse('https://wa.me/$_phoneRaw');

    var opened = false;

    try {
      opened = await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }

    if (!opened) {
      try {
        opened = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.supportOpenWhatsappError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                    title: l10n.drawerSupport,
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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary1,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: AppIcons.svg(
                                    'support',
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.drawerSupport,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.supportMessageTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.supportMessageSubtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.additional3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.additional2, height: 1),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 20,
                                color: AppColors.primary1,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                _phoneDisplay,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: FermerPlusBigButton(
                text: l10n.supportWriteWhatsapp,
                height: 50,
                borderRadius: 24,
                onPressed: () => _openWhatsApp(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

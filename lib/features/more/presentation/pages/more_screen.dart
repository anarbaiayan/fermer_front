import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      bottomNavIndex: 4,
      farmName: l10n.farmName,
      body: AppPage(
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          children: [
            Text(
              l10n.navMore,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary3,
              ),
            ),
            const SizedBox(height: 20),
            _MoreSection(
              title: l10n.morePrimarySection,
              items: [
                _MoreItem(
                  icon: 'home',
                  title: l10n.navHome,
                  color: AppColors.primary1,
                  onTap: () => context.go('/home'),
                ),
                _MoreItem(
                  icon: 'cow-bottom',
                  title: l10n.navHerd,
                  color: AppColors.primary2,
                  onTap: () => context.go('/herd'),
                ),
                _MoreItem(
                  icon: 'events',
                  title: l10n.navEvents,
                  color: AppColors.accent,
                  onTap: () => context.go('/events'),
                ),
                _MoreItem(
                  icon: 'lactation',
                  title: l10n.navLactation,
                  color: const Color(0xFF4A78C1),
                  onTap: () => context.go('/lactation'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _MoreSection(
              title: l10n.moreFarmSection,
              items: [
                _MoreItem(
                  icon: 'diet1',
                  title: l10n.navRation,
                  color: AppColors.primary2,
                  onTap: () => context.push('/rations'),
                ),
                _MoreItem(
                  icon: 'inventory',
                  title: l10n.rationsFeedStock,
                  color: const Color(0xFF4A78C1),
                  onTap: () => context.push('/rations/stocks'),
                ),
                _MoreItem(
                  icon: 'medicine',
                  title: l10n.pharmacyTitle,
                  color: AppColors.primary1,
                  onTap: () => context.push('/pharmacy'),
                ),
                _MoreItem(
                  icon: 'checklist',
                  title: l10n.pharmacyMyRequests,
                  color: AppColors.accent,
                  onTap: () => context.push('/pharmacy/requests'),
                ),
                _MoreItem(
                  icon: 'health',
                  title: l10n.vetConsultantsTitle,
                  color: const Color(0xFF4A78C1),
                  onTap: () => context.push('/vet-consultants'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _MoreSection(
              title: l10n.moreAccountSection,
              items: [
                _MoreItem(
                  icon: 'user',
                  title: l10n.drawerProfile,
                  color: AppColors.primary2,
                  onTap: () => context.push('/profile'),
                ),
                _MoreItem(
                  icon: 'settings',
                  title: l10n.drawerSettings,
                  color: AppColors.primary1,
                  onTap: () => context.push('/settings'),
                ),
                _MoreItem(
                  icon: 'bell',
                  title: l10n.notificationsTitle,
                  color: const Color(0xFF4A78C1),
                  onTap: () => context.push('/notifications'),
                ),
                _MoreItem(
                  icon: 'support',
                  title: l10n.drawerSupport,
                  color: AppColors.accent,
                  onTap: () => context.push('/support'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreSection extends StatelessWidget {
  final String title;
  final List<_MoreItem> items;

  const _MoreSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 9),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: AppColors.additional3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.additional2),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(213, 215, 218, 0.18),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                items[index],
                if (index < items.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 68),
                    child: Divider(height: 1, color: AppColors.additional2),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreItem extends StatelessWidget {
  final String icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: AppIcons.svg(icon, size: 22, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title.replaceAll('\n', ' '),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: AppColors.additional3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

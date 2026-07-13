import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/rations/presentation/widgets/cattle_ration_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/rations_providers.dart';

class RationsScreen extends ConsumerWidget {
  final int? cattleId;

  const RationsScreen({super.key, this.cattleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final availableAsync = ref.watch(userAvailableRationsProvider);
    final rationsAsync = ref.watch(cattleRationsProvider);

    final cattleRationAsync = (cattleId == null)
        ? const AsyncValue.data(null)
        : ref.watch(cattleRationByCattleProvider(cattleId!));

    final isFromCattle = cattleId != null;

    return AppScaffold(
      bottomNavIndex: 4,
      enableDrawer: true,
      showBell: true,
      showAppBar: true,
      farmName: l10n.farmName,
      body: AppPage(
        child: availableAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) {
            final msg = _errorText(e);
            if (_isNoAvailableFeedsError(e)) {
              return _EmptyRationsState(
                onAdd: () => context.push('/rations/stocks/add'),
              );
            }

            return Center(
              child: Text(l10n.errorPrefix(msg), textAlign: TextAlign.center),
            );
          },
          data: (available) {
            if (available.isEmpty) {
              return _EmptyRationsState(
                onAdd: () => context.push('/rations/stocks/add'),
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const SizedBox(height: 10),
                _Header(
                  title: isFromCattle
                      ? l10n.rationsForAnimalTitle
                      : l10n.rationsListTitle,
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  trailing: isFromCattle
                      ? null
                      : IconButton(
                          padding: EdgeInsets.zero,
                          icon: AppIcons.svg('filter', size: 32),
                          onPressed: () {},
                        ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      l10n.rationsFeedStock,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary3,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => context.push('/rations/stocks'),
                      child: const Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 116,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _StockTypeChip(
                        title: l10n.rationsConcentrates,
                        color: const Color(0xFF4A78C1),
                        onTap: () =>
                            context.push('/rations/stocks/CONCENTRATED'),
                      ),
                      _StockTypeChip(
                        title: l10n.rationsSucculentFeed,
                        color: const Color(0xFFF7DFA3),
                        onTap: () => context.push('/rations/stocks/JUICY'),
                      ),
                      _StockTypeChip(
                        title: l10n.rationsRoughage,
                        color: const Color(0xFFB7E4C7),
                        onTap: () => context.push('/rations/stocks/COARSE'),
                      ),
                      _StockTypeChip(
                        title: l10n.rationsAdditives,
                        color: const Color(0xFFF4C2C2),
                        onTap: () => context.push(
                          '/rations/stocks/VITAMINS_SUPPLEMENTS',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                if (isFromCattle) ...[
                  cattleRationAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        l10n.errorPrefix(_errorText(e)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    data: (ration) {
                      if (ration == null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Center(
                            child: Text(
                              l10n.rationsNotGenerated,
                              style: const TextStyle(
                                color: AppColors.additional3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CattleRationCard(
                          ration: ration,
                          variant: CattleRationCardVariant.fromCattle,
                          onTap: () =>
                              context.push('/rations/cattle/${cattleId!}'),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  rationsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        l10n.errorPrefix(_errorText(e)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    data: (rations) {
                      if (rations.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Center(
                            child: Text(
                              l10n.rationsNotGenerated,
                              style: const TextStyle(
                                color: AppColors.additional3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          const SizedBox(height: 6),
                          ...rations.map((r) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CattleRationCard(
                                ration: r,
                                variant: CattleRationCardVariant.overview,
                                onTap: null,
                                onDelete: () async {
                                  final del = ref.read(
                                    deleteCattleRationProvider,
                                  );
                                  await del(r.id);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.rationsDeleted),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _errorText(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }

  bool _isNoAvailableFeedsError(Object error) {
    if (error is! ApiException) return false;

    const ruNoFeeds =
        '\u043d\u0435\u0442 \u0434\u043e\u0441\u0442\u0443\u043f\u043d\u044b\u0445 \u043a\u043e\u0440\u043c\u043e\u0432';
    const ruAddFeeds =
        '\u0434\u043e\u0431\u0430\u0432\u044c\u0442\u0435 \u043a\u043e\u0440\u043c\u0430';
    const kkFeedWord = '\u0436\u0435\u043c';

    final lower = error.message.toLowerCase();

    return lower.contains(ruNoFeeds) ||
        lower.contains(ruAddFeeds) ||
        lower.contains('no available feeds') ||
        (lower.contains(kkFeedWord) && lower.contains('available')) ||
        (error.statusCode == 500 &&
            lower.contains('unexpected error occurred') &&
            (lower.contains(ruAddFeeds) || lower.contains(kkFeedWord)));
  }
}

class _EmptyRationsState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyRationsState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: AppPage(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/image/noResult.png', width: 260),
            const SizedBox(height: 24),
            Text(
              l10n.rationsEmptyTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.rationsEmptySubtitle,
              style: const TextStyle(fontSize: 14, color: AppColors.primary3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 55),
            SizedBox(
              width: double.infinity,
              child: FermerPlusBigButton(
                text: l10n.rationsAddFeedStock,
                onPressed: onAdd,
                height: 50,
                borderRadius: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  const _Header({required this.title, required this.onBack, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          icon: AppIcons.svg('arrow', size: 32),
          onPressed: onBack,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary3,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StockTypeChip extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _StockTypeChip({required this.title, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 146,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.additional2),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: AppIcons.svg('inventory', size: 18, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

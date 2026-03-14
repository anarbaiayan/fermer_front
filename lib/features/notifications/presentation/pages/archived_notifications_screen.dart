import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ArchivedNotificationsScreen extends ConsumerStatefulWidget {
  const ArchivedNotificationsScreen({super.key});

  @override
  ConsumerState<ArchivedNotificationsScreen> createState() =>
      _ArchivedNotificationsScreenState();
}

class _ArchivedNotificationsScreenState
    extends ConsumerState<ArchivedNotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      ref.read(notificationsFeedProvider(true).notifier).loadMore();
    }
  }

  Future<void> _onTapNotification(int id, int? cattleId) async {
    final notifier = ref.read(notificationsFeedProvider(true).notifier);

    try {
      await notifier.markAsRead(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorPrefix('$e'))),
      );
    }

    if (!mounted || cattleId == null) return;
    context.push('/herd/$cattleId');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncFeed = ref.watch(notificationsFeedProvider(true));

    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: true,
      showBell: false,
      farmName: l10n.farmName,
      body: AppPage(
        child: Column(
          children: [
            HerdPageHeader(
              title: l10n.notificationsArchivedTitle,
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: asyncFeed.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(l10n.errorPrefix('$e'))),
                data: (feed) {
                  return feed.items.isEmpty
                      ? Center(
                          child: Text(
                            l10n.notificationsArchivedEmpty,
                            style: const TextStyle(
                              color: AppColors.additional3,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(notificationsFeedProvider(true).notifier)
                              .refresh(),
                          child: ListView.separated(
                            controller: _scrollController,
                            itemCount: feed.items.length + (feed.isLoadingMore ? 1 : 0),
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              if (index >= feed.items.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final n = feed.items[index];
                              return NotificationTile(
                                notification: n,
                                onTap: () =>
                                    _onTapNotification(n.id, n.cattleInfo?.cattleId),
                              );
                            },
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

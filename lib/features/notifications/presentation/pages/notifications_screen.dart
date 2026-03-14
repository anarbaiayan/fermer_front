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

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
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
      ref.read(notificationsFeedProvider(false).notifier).loadMore();
    }
  }

  Future<void> _onTapNotification(int id, int? cattleId) async {
    final notifier = ref.read(notificationsFeedProvider(false).notifier);

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

  Future<bool> _onArchive(int id) async {
    final notifier = ref.read(notificationsFeedProvider(false).notifier);
    try {
      await notifier.archive(id);
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix('$e'))),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncFeed = ref.watch(notificationsFeedProvider(false));

    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: true,
      showBell: false,
      farmName: l10n.farmName,
      body: AppPage(
        child: Column(
          children: [
            Expanded(
              child: asyncFeed.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorState(
                  text: l10n.errorPrefix('$e'),
                  onRetry: () =>
                      ref.read(notificationsFeedProvider(false).notifier).refresh(),
                ),
                data: (feed) {
                  return Column(
                    children: [
                      HerdPageHeader(
                        title: l10n.notificationsTitle,
                        onBack: () => context.pop(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/notifications/archived'),
                            child: Text(
                              l10n.notificationsViewArchived,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: feed.items.isEmpty
                            ? Center(
                                child: Text(
                                  l10n.notificationsEmpty,
                                  style: const TextStyle(
                                    color: AppColors.additional3,
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () => ref
                                    .read(notificationsFeedProvider(false).notifier)
                                    .refresh(),
                                child: ListView.separated(
                                  controller: _scrollController,
                                  itemCount:
                                      feed.items.length + (feed.isLoadingMore ? 1 : 0),
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 10),
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
                                    return Dismissible(
                                      key: ValueKey(n.id),
                                      direction: DismissDirection.endToStart,
                                      confirmDismiss: (_) => _onArchive(n.id),
                                      background: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          l10n.notificationsArchiveAction,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      child: NotificationTile(
                                        notification: n,
                                        onTap: () => _onTapNotification(
                                          n.id,
                                          n.cattleInfo?.cattleId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
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

class _ErrorState extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _ErrorState({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(text, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

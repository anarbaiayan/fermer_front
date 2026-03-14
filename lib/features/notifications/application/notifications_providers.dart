import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/datasources/notifications_api.dart';
import '../domain/entities/app_notification.dart';

class NotificationsFeedState {
  final List<AppNotification> items;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationsFeedState({
    required this.items,
    required this.nextPage,
    required this.hasMore,
    required this.isLoadingMore,
  });

  NotificationsFeedState copyWith({
    List<AppNotification>? items,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationsFeedState(
      items: items ?? this.items,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final api = ref.read(notificationsApiProvider);
  return api.getUnreadCount();
});

class NotificationsFeedController
    extends AutoDisposeFamilyAsyncNotifier<NotificationsFeedState, bool> {
  static const _pageSize = 20;
  late bool _archived;

  @override
  Future<NotificationsFeedState> build(bool archived) async {
    _archived = archived;
    return _loadFirstPage();
  }

  Future<NotificationsFeedState> _loadFirstPage() async {
    final api = ref.read(notificationsApiProvider);
    final page = _archived
        ? await api.getArchivedNotifications(page: 0, size: _pageSize)
        : await api.getNotifications(page: 0, size: _pageSize);
    return NotificationsFeedState(
      items: page.toEntities(),
      nextPage: 1,
      hasMore: !page.last,
      isLoadingMore: false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadFirstPage);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final api = ref.read(notificationsApiProvider);
      final page = _archived
          ? await api.getArchivedNotifications(
              page: current.nextPage,
              size: _pageSize,
            )
          : await api.getNotifications(page: current.nextPage, size: _pageSize);

      final merged = [...current.items, ...page.toEntities()];
      state = AsyncData(
        current.copyWith(
          items: merged,
          nextPage: current.nextPage + 1,
          hasMore: !page.last,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final idx = current.items.indexWhere((x) => x.id == notificationId);
    if (idx < 0) return;

    final target = current.items[idx];
    final api = ref.read(notificationsApiProvider);
    await api.markAsRead(notificationId);

    if (target.isUnread) {
      final updated = [...current.items];
      updated[idx] = target.copyWith(readAt: DateTime.now());
      state = AsyncData(current.copyWith(items: updated));
    }

    ref.invalidate(unreadNotificationsCountProvider);
  }

  Future<void> archive(int notificationId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final api = ref.read(notificationsApiProvider);
    await api.archive(notificationId);

    if (!_archived) {
      final updated = current.items.where((x) => x.id != notificationId).toList();
      state = AsyncData(current.copyWith(items: updated));
    }

    ref.invalidate(unreadNotificationsCountProvider);
  }
}

final notificationsFeedProvider = AutoDisposeAsyncNotifierProviderFamily<
  NotificationsFeedController,
  NotificationsFeedState,
  bool
>(NotificationsFeedController.new);

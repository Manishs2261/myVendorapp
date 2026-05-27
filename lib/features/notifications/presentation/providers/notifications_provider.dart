import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/notification_remote_source.dart';
import '../../domain/notification_model.dart';

final notificationRemoteSourceProvider = Provider<NotificationRemoteSource>(
  (ref) => NotificationRemoteSource(ref.read(dioProvider)),
);

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    final source = ref.read(notificationRemoteSourceProvider);
    final data = await source.getNotifications();
    final items = data['items'] as List? ?? [];
    return items
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationRemoteSourceProvider).markRead(id);
    state = state.whenData(
      (items) => items.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
  }

  Future<void> markAllRead() async {
    await ref.read(notificationRemoteSourceProvider).markAllRead();
    state = state.whenData(
      (items) => items.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final notificationsNotifierProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  NotificationsNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsNotifierProvider).maybeWhen(
    data: (items) => items.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

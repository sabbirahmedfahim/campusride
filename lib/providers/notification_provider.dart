import 'package:flutter/material.dart';
import '../api/notification_api.dart';
import '../entities/notification_item.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationApi _api = NotificationApi();

  List<NotificationItem> items = [];
  int unreadCount = 0;
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    items = await _api.fetchMyNotifications();
    unreadCount = items.where((n) => !n.isRead).length;
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshUnreadCount() async {
    unreadCount = await _api.fetchUnreadCount();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    await _api.markAllRead();
    unreadCount = 0;
    items = items.map((n) => NotificationItem(
      id: n.id,
      userId: n.userId,
      rideId: n.rideId,
      type: n.type,
      isRead: true,
      createdAt: n.createdAt,
      rideDirection: n.rideDirection,
      riderName: n.riderName,
    )).toList();
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class NotificationItemModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final IconData icon;
  final String category; // 'order', 'wallet', 'promo', 'account'
  bool isRead;

  NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.icon,
    this.category = 'system',
    this.isRead = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal() {
    _initDefaultNotifications();
  }

  final ValueNotifier<List<NotificationItemModel>> notificationsNotifier =
      ValueNotifier<List<NotificationItemModel>>([]);

  List<NotificationItemModel> get items => notificationsNotifier.value;

  int get unreadCount => items.where((n) => !n.isRead).length;

  void _initDefaultNotifications() {
    final now = DateTime.now();
    notificationsNotifier.value = [
      NotificationItemModel(
        id: 'n1',
        title: 'Welcome to StyClick!',
        message: 'Your bespoke fashion journey begins here. Explore top tailors & designers.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        icon: FeatherIcons.star,
        category: 'system',
        isRead: false,
      ),
      NotificationItemModel(
        id: 'n2',
        title: 'Order Status Update',
        message: 'Your Bespoke Aso-Ebi order #4290 is currently being processed by the designer.',
        timestamp: now.subtract(const Duration(hours: 1)),
        icon: FeatherIcons.package,
        category: 'order',
        isRead: false,
      ),
      NotificationItemModel(
        id: 'n3',
        title: 'Special Promotion',
        message: 'Get 20% off on all premium Ankara & Lace fabrics this weekend!',
        timestamp: now.subtract(const Duration(hours: 4)),
        icon: FeatherIcons.tag,
        category: 'promo',
        isRead: true,
      ),
      NotificationItemModel(
        id: 'n4',
        title: 'Measurements Saved',
        message: 'Your body measurement profile has been updated successfully.',
        timestamp: now.subtract(const Duration(hours: 12)),
        icon: FeatherIcons.userCheck,
        category: 'account',
        isRead: true,
      ),
      NotificationItemModel(
        id: 'n5',
        title: 'Wallet Funded',
        message: 'Your StyClick wallet was successfully credited with NGN 50,000.',
        timestamp: now.subtract(const Duration(days: 1)),
        icon: FeatherIcons.creditCard,
        category: 'wallet',
        isRead: true,
      ),
    ];
  }

  void addNotification({
    required String title,
    required String message,
    required IconData icon,
    String category = 'system',
  }) {
    final newItem = NotificationItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      icon: icon,
      category: category,
      isRead: false,
    );
    notificationsNotifier.value = [newItem, ...notificationsNotifier.value];
  }

  void markAsRead(String id) {
    notificationsNotifier.value = notificationsNotifier.value.map((n) {
      if (n.id == id) {
        n.isRead = true;
      }
      return n;
    }).toList();
  }

  void markAllAsRead() {
    notificationsNotifier.value = notificationsNotifier.value.map((n) {
      n.isRead = true;
      return n;
    }).toList();
  }

  void removeNotification(String id) {
    notificationsNotifier.value =
        notificationsNotifier.value.where((n) => n.id != id).toList();
  }

  void clearAll() {
    notificationsNotifier.value = [];
  }
}

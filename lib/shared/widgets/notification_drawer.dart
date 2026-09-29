import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import '../constants/colors.dart';
import '../services/notification_service.dart';

Widget buildNotificationDrawer(BuildContext context) {
  return const NotificationDrawer();
}

class NotificationDrawer extends StatelessWidget {
  const NotificationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = NotificationService.instance;

    return Drawer(
      child: Container(
        color: cream,
        child: SafeArea(
          child: ValueListenableBuilder<List<NotificationItemModel>>(
            valueListenable: service.notificationsNotifier,
            builder: (context, notifications, child) {
              final unread = service.unreadCount;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.height,
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Notifications',
                                style: GoogleFonts.montserrat(
                                  fontSize: 20.sp,
                                  color: ink,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (unread > 0) ...[
                                8.width,
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    '$unread new',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(FeatherIcons.x, color: ink, size: 20.sp),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Bar
                  if (notifications.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (unread > 0)
                            TextButton.icon(
                              onPressed: () => service.markAllAsRead(),
                              icon: Icon(FeatherIcons.checkSquare, size: 14.sp, color: primary),
                              label: Text(
                                'Mark all as read',
                                style: TextStyle(fontSize: 12.sp, color: primary, fontWeight: FontWeight.w500),
                              ),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            )
                          else
                            const SizedBox.shrink(),
                          TextButton.icon(
                            onPressed: () {
                              showConfirmDialogCustom(
                                context,
                                title: 'Clear all notifications?',
                                primaryColor: primary,
                                positiveText: 'Clear All',
                                negativeText: 'Cancel',
                                onAccept: (c) => service.clearAll(),
                              );
                            },
                            icon: Icon(FeatherIcons.trash2, size: 14.sp, color: textLight),
                            label: Text(
                              'Clear all',
                              style: TextStyle(fontSize: 12.sp, color: textLight, fontWeight: FontWeight.w500),
                            ),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Divider(color: sand, thickness: 1),
                  ),

                  // Notification List
                  Expanded(
                    child: notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20.w),
                                  decoration: BoxDecoration(
                                    color: sand.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(FeatherIcons.bellOff, size: 36.sp, color: textLight),
                                ),
                                16.height,
                                Text(
                                  'No notifications',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: ink,
                                  ),
                                ),
                                6.height,
                                Text(
                                  'You\'re all caught up!',
                                  style: TextStyle(fontSize: 13.sp, color: textLight),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            itemCount: notifications.length,
                            separatorBuilder: (context, index) => 10.height,
                            itemBuilder: (context, index) {
                              final item = notifications[index];
                              return _NotificationTile(
                                item: item,
                                onTap: () => service.markAsRead(item.id),
                                onDelete: () => service.removeNotification(item.id),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItemModel item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(FeatherIcons.trash, color: Colors.red, size: 20.sp),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : primary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: item.isRead ? sand : primary.withOpacity(0.2),
              width: item.isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: item.isRead ? sand.withOpacity(0.5) : primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.isRead ? textLight : primary,
                  size: 18.sp,
                ),
              ),
              12.width,
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'Cinta',
                              fontSize: 13.sp,
                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                              color: ink,
                            ),
                          ),
                        ),
                        Text(
                          item.timeAgo,
                          style: TextStyle(fontSize: 10.sp, color: textLight),
                        ),
                      ],
                    ),
                    4.height,
                    Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: item.isRead ? textLight : ink.withOpacity(0.85),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (!item.isRead) ...[
                6.width,
                Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

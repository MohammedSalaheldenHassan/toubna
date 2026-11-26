import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/page_header.dart';
import 'package:toubna/features/notifications/notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Obx(() {
            final enabled = controller.enabled.value;
            final unread = controller.unreadCount;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: PageHeader(title: 'الإشعارات'.tr)),
                    if (enabled && unread > 0)
                      TextButton(
                        onPressed: controller.markAllRead,
                        child: Text('قراءة الكل'.tr),
                      ),
                  ],
                ),
                if (!enabled)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffFBEFD0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_off_outlined,
                          color: Color(0xff7A4A00),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'الإشعارات مقفولة، فما هتوصلك تنبيهات الطلبات والعروض.'
                                .tr,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff7A4A00),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => controller.setEnabled(true),
                          child: Text('تفعيل'.tr),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 16, bottom: 20),
                    itemCount: controller.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = controller.items[i];
                      final read = controller.isRead(n) || !enabled;
                      return _NotificationTile(
                        notification: n,
                        unread: !read,
                        onTap: () => controller.open(n),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final bool unread;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: unread ? const Color(0xFFFDF8FA) : Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: unread
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(notification.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: unread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsetsDirectional.only(start: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textBody,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

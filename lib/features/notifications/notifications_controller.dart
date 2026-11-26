import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/app_storage.dart';

class AppNotification {
  final String id;
  final String titleKey;
  final String bodyKey;
  final String timeKey;
  final IconData icon;

  /// الصفحة اللي بتفتح لما المستخدمة تضغط الإشعار.
  final String route;
  final Object? arguments;

  const AppNotification({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.timeKey,
    required this.icon,
    required this.route,
    this.arguments,
  });

  String get title => titleKey.tr;
  String get body => bodyKey.tr;
  String get time => timeKey.tr;
}

/// الإشعارات على مستوى التطبيق (نقطة الجرس في الرئيسية + صفحة الإشعارات
/// + زر الإشعارات في حسابي).
class NotificationsController extends GetxController {
  // بيانات تجريبية — لاحقًا من الـ API / Firebase Cloud Messaging
  final items = const [
    AppNotification(
      id: 'n1',
      titleKey: 'طلبك خرج للتوصيل',
      bodyKey: 'طلب #TB-20455 مع المندوب وهيوصلك اليوم قبل 6:00 م.',
      timeKey: 'قبل 20 دقيقة',
      icon: Icons.local_shipping_outlined,
      route: AppRoutes.trackOrder,
      arguments: '#TB-20455',
    ),
    AppNotification(
      id: 'n2',
      titleKey: 'بنجهّز طلبك',
      bodyKey: 'استلمنا طلب #TB-20481 وبنغلّف توبك بعناية.',
      timeKey: 'قبل ساعتين',
      icon: Icons.inventory_2_outlined,
      route: AppRoutes.trackOrder,
      arguments: '#TB-20481',
    ),
    AppNotification(
      id: 'n3',
      titleKey: 'خصم حتى 30٪ على القرمصيص',
      bodyKey: 'موسم الأعراس وصل! اختاري توبك قبل ما العرض يخلص.',
      timeKey: 'أمس',
      icon: Icons.local_offer_outlined,
      route: AppRoutes.category,
      arguments: 'garmasis',
    ),
    AppNotification(
      id: 'n4',
      titleKey: 'وصلت تشكيلة شيفون جديدة',
      bodyKey: 'ألوان متدرّجة وناعمة للزيارات والمناسبات.',
      timeKey: 'قبل 3 أيام',
      icon: Icons.auto_awesome_outlined,
      route: AppRoutes.category,
      arguments: 'chiffon',
    ),
  ];

  final readIds = <String>{}.obs;

  /// مفتاح الإشعارات في حسابي (بيتحفظ على الجهاز).
  final enabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  Future<void> _restore() async {
    enabled.value =
        await AppStorage.readBool(AppStorage.notificationsKey) ?? true;
  }

  bool isRead(AppNotification n) => readIds.contains(n.id);

  int get unreadCount =>
      enabled.value ? items.where((n) => !readIds.contains(n.id)).length : 0;

  void markAllRead() => readIds.addAll(items.map((n) => n.id));

  void open(AppNotification n) {
    readIds.add(n.id);
    Get.toNamed(n.route, arguments: n.arguments);
  }

  Future<void> setEnabled(bool value) async {
    enabled.value = value;
    // هنا لاحقًا: تسجيل/إلغاء توكن الإشعارات مع السيرفر
    await AppStorage.writeBool(AppStorage.notificationsKey, value);
  }
}

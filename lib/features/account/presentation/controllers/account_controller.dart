import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/i18n/locale_controller.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/features/notifications/notifications_controller.dart';
import 'package:toubna/core/services/favorites_controller.dart';
import 'package:toubna/core/services/user_controller.dart';
import 'package:toubna/features/addresses/presentation/controllers/addresses_controller.dart';
import 'package:toubna/features/my_order/data/order_models.dart';
import 'package:toubna/features/my_order/presentation/controllers/my_order_controller.dart';
import 'package:toubna/features/routes/main_shell_controller.dart';

class AccountController extends GetxController {
  final UserController user = Get.find<UserController>();
  final AddressesController addresses = Get.find<AddressesController>();
  final MyOrderController orders = Get.find<MyOrderController>();
  final _favorites = Get.find<FavoritesController>();

  int get ordersCount => orders.currentOrders.length + orders.pastOrders.length;
  int get favoritesCount => _favorites.count;
  int get addressesCount => addresses.count;

  /// أحدث طلب لسه ما وصل (يظهر ككارت متابعة سريعة).
  Order? get activeOrder =>
      orders.currentOrders.isEmpty ? null : orders.currentOrders.first;

  static const appVersion = '1.0.0';

  final NotificationsController _notifications =
      Get.find<NotificationsController>();
  RxBool get notificationsOn => _notifications.enabled;

  void toggleNotifications(bool value) => _notifications.setEnabled(value);

  final LocaleController _locale = Get.find<LocaleController>();

  /// 0 العربية، 1 English — التبديل بيغيّر لغة واتجاه التطبيق كله ويتحفظ.
  int get selectedLang => _locale.isArabic ? 0 : 1;

  void selectLanguage(int index) => _locale.change(
    index == 0 ? LocaleController.arabic : LocaleController.english,
  );

  void openEditProfile() => Get.toNamed(AppRoutes.editProfile);
  void openOrders() =>
      Get.find<MainShellController>().changeTab(MainShellController.ordersTab);
  void openTracking(Order order) => orders.openTracking(order);
  void openFavorites() => Get.toNamed(AppRoutes.favorites);
  void openLocations() => Get.toNamed(AppRoutes.locations);
  void openContactUs() => Get.toNamed(AppRoutes.contactUs);
  void openTerms() => Get.toNamed(AppRoutes.terms);

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تسجيل الخروج'.tr,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'متأكدة إنك عايزة تسجّلي خروج؟'.tr,
          style: TextStyle(fontSize: 15, color: Color(0xFF4A3F46)),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('إلغاء'.tr, style: TextStyle(color: Color(0xFF6B5E66))),
          ),
          TextButton(
            onPressed: _logout,
            child: Text(
              'تسجيل الخروج'.tr,
              style: TextStyle(
                color: Color(0xffA61B1B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // هنا لاحقًا: تمسح الجلسة المحفوظة
    Get.offAllNamed(AppRoutes.login);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/features/account/presentation/pages/account_screen.dart';
import 'package:toubna/features/cart/presentation/cart_screen.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';
import 'package:toubna/features/categories/presentation/pages/categories_screen.dart';
import 'package:toubna/features/home/presentation/pages/home_screen.dart';
import 'package:toubna/features/my_order/presentation/pages/my_order_screen.dart';
import 'package:toubna/features/routes/main_shell_controller.dart';

class MainShell extends GetView<MainShellController> {
  const MainShell({super.key});

  static const List<Widget> pages = [
    HomeScreen(),
    CategoriesScreen(),
    CartScreen(),
    MyOrderScreen(),
    AccountScreen(),
  ];

  Widget _icon(String name) =>
      ImageIcon(AssetImage('assets/icons/$name.png'), size: 30);

  @override
  Widget build(BuildContext context) {
    // على الشاشات الصغيرة نصغّر النص شوية عشان الخمس عناصر ما تتزاحم
    // الكلمات الإنجليزية أطول ("Categories"، "My orders") فبنصغّرها شوية
    final english = Get.locale?.languageCode == 'en';
    final labelSize = MediaQuery.sizeOf(context).width < 380
        ? (english ? 12.0 : 14.0)
        : (english ? 14.0 : 18.0);
    final cart = Get.find<CartController>();
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            border: Border(top: BorderSide(color: Color(0xFFEADFE3))),
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFFFFFFF),
            elevation: 0,
            selectedItemColor: const Color(0xFF7A1F4B),
            unselectedItemColor: const Color(0xFF6B5E66),
            selectedFontSize: labelSize,
            unselectedFontSize: labelSize,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            items: [
              BottomNavigationBarItem(
                icon: _icon('home'),
                label: 'الرئيسية'.tr,
              ),
              BottomNavigationBarItem(
                icon: _icon('categories'),
                label: 'الأقسام'.tr,
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: cart.count > 0,
                  label: Text('${cart.count}'),
                  backgroundColor: const Color(0xFF7A1F4B),
                  child: _icon('bag'),
                ),
                label: 'السلة'.tr,
              ),
              BottomNavigationBarItem(
                icon: _icon('orders'),
                label: 'طلباتي'.tr,
              ),
              BottomNavigationBarItem(icon: _icon('user'), label: 'حسابي'.tr),
            ],
          ),
        ),
      ),
    );
  }
}

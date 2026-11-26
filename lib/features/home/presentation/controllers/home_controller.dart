import 'package:toubna/core/data/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/features/notifications/notifications_controller.dart';
import 'package:toubna/core/services/connectivity_service.dart';
import 'package:toubna/core/services/favorites_controller.dart';
import 'package:toubna/core/utils/simulated_loading.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';
import 'package:toubna/features/routes/main_shell_controller.dart';

class PromoSlide {
  final String badgeKey;
  final String titleKey;
  final String subtitleKey;
  final String ctaKey;
  final String image;
  final Color color;
  final String categoryId;

  PromoSlide({
    required String badge,
    required String title,
    required String subtitle,
    required this.image,
    required this.color,
    required this.categoryId,
    String cta = 'تسوقي الآن',
  }) : badgeKey = badge,
       titleKey = title,
       subtitleKey = subtitle,
       ctaKey = cta;

  String get badge => badgeKey.tr;
  String get title => titleKey.tr;
  String get subtitle => subtitleKey.tr;
  String get cta => ctaKey.tr;
}

class Occasion {
  final String titleKey;
  final String subKey;
  final String image;
  final String categoryId;

  const Occasion(this.titleKey, this.subKey, this.image, this.categoryId);

  String get title => titleKey.tr;
  String get sub => subKey.tr;
}

class HomeController extends GetxController with LoadingState {
  static const newArrivalsPageSize = 2;
  static const newArrivalsMax = 8;

  // بيانات تجريبية — لاحقًا تجي من الـ API
  final promos = [
    PromoSlide(
      badge: 'موسم الأعراس',
      title: 'خصم حتى 30٪',
      subtitle: 'على توب القرمصيص',
      image: AppImages.promoWedding,
      color: Color(0xff7A1F4B),
      categoryId: 'garmasis',
    ),
    PromoSlide(
      badge: 'وصل حديثًا',
      title: 'تشكيلة الشيفون',
      subtitle: 'ألوان ناعمة للزيارات',
      image: AppImages.promoChiffon,
      color: Color(0xFF1F5C6B),
      categoryId: 'chiffon',
    ),
    PromoSlide(
      badge: 'لفترة محدودة',
      title: 'توصيل مجاني',
      subtitle: 'للطلبات فوق 100,000 ج.س',
      image: AppImages.promoFreeDelivery,
      color: Color(0xFF3B2F6B),
      categoryId: 'swiss',
      cta: 'اكتشفي السويسري',
    ),
  ];

  final occasions = const [
    Occasion(
      'أعراس',
      'قرمصيص ومشغول · 36 توب',
      AppImages.occasionWedding,
      'garmasis',
    ),
    Occasion('العيد', 'ألوان مبهجة · 24 توب', AppImages.occasionEid, 'silk'),
    Occasion('الدوام', 'فوال عملي · 41 توب', AppImages.occasionWork, 'foal'),
    Occasion(
      'الزيارات',
      'شيفون ناعم · 29 توب',
      AppImages.occasionVisits,
      'chiffon',
    ),
  ];

  final featuredProducts = Products.bestSellers(4);
  final newArrivals = Products.newArrivals.take(newArrivalsMax).toList();

  final newArrivalCount = newArrivalsPageSize.obs;

  final FavoritesController favorites = Get.find<FavoritesController>();

  @override
  void onInit() {
    super.onInit();
    load(); // هنا لاحقًا: load(() => api.fetchHome())
  }

  List<Product> get visibleNewArrivals =>
      newArrivals.take(newArrivalCount.value).toList();

  bool get canLoadMore => newArrivalCount.value < newArrivals.length;

  bool isFavorite(Product p) => favorites.isFavorite(p);

  void toggleFavorite(Product p) => favorites.toggle(p);

  void loadMoreNewArrivals() {
    newArrivalCount.value = (newArrivalCount.value + newArrivalsPageSize).clamp(
      0,
      newArrivals.length,
    );
  }

  void addToCart(Product p) => Get.find<CartController>().addProduct(p);

  /// السحب لتحديث الصفحة.
  Future<void> refreshHome() async {
    if (!requireOnline()) return;
    // هنا لاحقًا: تعيد تحميل البيانات من الـ API
    await Future.delayed(const Duration(milliseconds: 800));
    newArrivalCount.value = newArrivalsPageSize;
  }

  void openProduct(Product p) =>
      Get.toNamed(AppRoutes.product, arguments: p.id);

  void openFavorites() => Get.toNamed(AppRoutes.favorites);

  final NotificationsController notifications =
      Get.find<NotificationsController>();

  void openNotifications() => Get.toNamed(AppRoutes.notifications);

  void openSearch() =>
      Get.toNamed(AppRoutes.search, arguments: {'focus': true});

  void openAllProducts() => Get.toNamed(AppRoutes.search);

  void openCategory(String id) =>
      Get.toNamed(AppRoutes.category, arguments: id);

  void openCategories() => Get.find<MainShellController>().changeTab(1);
}

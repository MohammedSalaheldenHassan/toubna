import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/app_storage.dart';

class OnboardingPage {
  final String titleKey;
  final String bodyKey;

  const OnboardingPage(this.titleKey, this.bodyKey);

  String get title => titleKey.tr;
  String get body => bodyKey.tr;
}

class OnboardingController extends GetxController {
  static const pages = [
    OnboardingPage(
      'كل التياب في مكان واحد',
      'سويسري، قرمصيص، شيفون ومشغول… تشكيلة مختارة بعناية لكل ذوق.',
    ),
    OnboardingPage(
      'اختاري لونك وطولك',
      'شوفي التوب بكل ألوانه، واختاري الطول المناسب ليك قبل ما تطلبي.',
    ),
    OnboardingPage(
      'لحد باب بيتك',
      'توصيل سريع لكل الولايات، وادفعي عند الاستلام بكل راحة.',
    ),
  ];

  final pageController = PageController();
  final page = 0.obs;

  bool get isLast => page.value == pages.length - 1;

  void onPageChanged(int i) => page.value = i;

  void next() {
    if (isLast) {
      register();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void skip() => pageController.animateToPage(
    pages.length - 1,
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOutCubic,
  );

  /// إنشاء حساب: الدخول يفضل تحتها عشان زر الرجوع يشتغل.
  Future<void> register() async {
    await _finish();
    Get.toNamed(AppRoutes.register);
  }

  Future<void> login() => _finish();

  Future<void> _finish() async {
    await AppStorage.setOnboardingSeen();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

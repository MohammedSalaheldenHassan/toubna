import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/app_storage.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 1800);
  static const _holdDuration = Duration(milliseconds: 900);

  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: _animationDuration,
  );

  // كل عنصر يظهر في جزء من مدة الحركة (حركة متتابعة)
  late final Animation<double> logoFade = _interval(0.0, 0.40, Curves.easeOut);
  // الشعار ظاهر من أول إطار (مطابق لشاشة النظام) مع نبضة خفيفة
  late final Animation<double> logoScale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 1),
  ]).animate(_interval(0.0, 0.45, Curves.easeInOut));
  late final Animation<double> wordmarkFade = _interval(
    0.30,
    0.70,
    Curves.easeOut,
  );
  late final Animation<Offset> wordmarkSlide = Tween(
    begin: const Offset(0, 0.35),
    end: Offset.zero,
  ).animate(_interval(0.30, 0.75, Curves.easeOutCubic));
  late final Animation<double> loaderFade = _interval(
    0.75,
    1.0,
    Curves.easeOut,
  );

  Animation<double> _interval(double begin, double end, Curve curve) =>
      CurvedAnimation(
        parent: animation,
        curve: Interval(begin, end, curve: curve),
      );

  @override
  void onReady() {
    super.onReady();
    // الشاشة الأصلية (Native) تبقى حتى أول إطار من فلاتر، بعدها نشغّل الحركة
    FlutterNativeSplash.remove();
    _start();
  }

  Future<void> _start() async {
    // نقرأ الإعدادات بالتوازي مع الحركة
    final seenOnboarding = AppStorage.isOnboardingSeen().catchError(
      (_) => false,
    );
    await animation.forward().orCancel.catchError((_) {});
    await Future.delayed(_holdDuration);
    final seen = await seenOnboarding;
    if (isClosed) return;
    // هنا لاحقًا: لو في جلسة محفوظة نوجّه للرئيسية مباشرة
    Get.offAllNamed(seen ? AppRoutes.login : AppRoutes.onboarding);
  }

  @override
  void onClose() {
    animation.dispose();
    super.onClose();
  }
}

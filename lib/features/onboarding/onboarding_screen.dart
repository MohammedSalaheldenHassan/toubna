import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toubna/core/data/app_images.dart';
import 'package:toubna/core/i18n/locale_controller.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/theme/app_theme.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:toubna/features/onboarding/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  static const _illustrations = [
    _CollageIllustration(),
    _ColorsIllustration(),
    _DeliveryIllustration(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const _TopBar(),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: OnboardingController.pages.length,
                  onPageChanged: controller.onPageChanged,
                  itemBuilder: (context, i) =>
                      _Page(index: i, illustration: _illustrations[i]),
                ),
              ),
              const _BottomControls(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends GetView<OnboardingController> {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 8, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Image.asset('assets/images/logo/logo_mark.png', width: 36),
            const SizedBox(width: 8),
            Text(
              'توبنا'.tr,
              style: TextStyle(
                fontFamily: AppTheme.displayFontFamily,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            // اختيار اللغة من أول شاشة (بيظهر اسم اللغة التانية)
            Obx(() {
              final locale = Get.find<LocaleController>();
              return TextButton.icon(
                onPressed: locale.toggle,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.primarySoft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.language, size: 18),
                label: Text(
                  locale.isArabic ? 'English' : 'العربية',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }),
            const SizedBox(width: 4),
            Obx(
              () => AnimatedOpacity(
                opacity: controller.isLast ? 0 : 1,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: controller.isLast,
                  child: TextButton(
                    onPressed: controller.skip,
                    child: Text(
                      'تخطي'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// صفحة واحدة: رسم + عنوان + وصف، مع حركة "parallax" وهي بتتسحب.
class _Page extends GetView<OnboardingController> {
  final int index;
  final Widget illustration;

  const _Page({required this.index, required this.illustration});

  @override
  Widget build(BuildContext context) {
    final page = OnboardingController.pages[index];
    return AnimatedBuilder(
      animation: controller.pageController,
      builder: (context, _) {
        final pc = controller.pageController;
        final current = pc.hasClients && pc.position.haveDimensions
            ? pc.page ?? controller.page.value.toDouble()
            : controller.page.value.toDouble();
        final delta = (current - index).clamp(-1.0, 1.0);
        final fade = 1 - delta.abs();
        return LayoutBuilder(
          builder: (context, constraints) {
            final art = math.min(constraints.maxHeight * 0.58, 340.0);
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // الرسم يتحرك أسرع من النص (عمق)
                      Transform.translate(
                        offset: Offset(delta * 90, 0),
                        child: Opacity(
                          opacity: fade.clamp(0.0, 1.0),
                          child: SizedBox(
                            height: art,
                            width: double.infinity,
                            child: illustration,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Transform.translate(
                        offset: Offset(delta * 40, 0),
                        child: Opacity(
                          opacity: fade.clamp(0.0, 1.0),
                          child: Column(
                            children: [
                              Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: AppTheme.displayFontFamily,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                page.body,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.7,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BottomControls extends GetView<OnboardingController> {
  const _BottomControls();

  @override
  Widget build(BuildContext context) {
    final count = OnboardingController.pages.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Obx(() {
        final page = controller.page.value;
        final last = controller.isLast;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'صفحة @p0 من @p1'.trParams({
                'p0': '${page + 1}',
                'p1': '$count',
              }),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(count, (i) {
                  final active = i == page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : const Color(0xFFD9B9C8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: controller.next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Row(
                    key: ValueKey(last),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        last ? 'ابدئي الآن'.tr : 'التالي'.tr,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        // arrow_forward بيتقلب تلقائيًا مع اتجاه اللغة
                        last
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // على الصفحة الأخيرة: رابط تسجيل الدخول لصاحبات الحسابات
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: last
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: TextButton(
                        onPressed: controller.login,
                        child: Text.rich(
                          TextSpan(
                            text: 'عندك حساب؟ '.tr,
                            style: TextStyle(color: AppColors.textMuted),
                            children: [
                              TextSpan(
                                text: 'سجّلي دخولك'.tr,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    )
                  : const SizedBox(height: 0, width: double.infinity),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------- الرسومات (من أقمشة الهوية) ----------------

/// قوس بشكل باب سوداني تقليدي، جواه صورة.
class _Arch extends StatelessWidget {
  final String image;
  final double width;
  final double height;

  const _Arch({required this.image, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(width / 2),
          bottom: const Radius.circular(22),
        ),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(width / 2 - 4),
          bottom: const Radius.circular(18),
        ),
        child: AppImage(image, width: width, height: height),
      ),
    );
  }
}

/// دائرة عنابية خلف الرسم بنقشة الهوية.
class _Backdrop extends StatelessWidget {
  final double size;

  const _Backdrop({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primarySoft,
      ),
    );
  }
}

class _GoldDots extends StatelessWidget {
  const _GoldDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (_) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// 1: ثلاث أقواس بأقمشة مختلفة.
class _CollageIllustration extends StatelessWidget {
  const _CollageIllustration();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final w = h * 0.42;
        return Stack(
          alignment: Alignment.center,
          children: [
            _Backdrop(size: h * 0.92),
            Transform.translate(
              offset: Offset(-w * 0.62, h * 0.06),
              child: Transform.rotate(
                angle: -0.14,
                child: _Arch(
                  image: AppImages.categoryGarmasis,
                  width: w * 0.85,
                  height: h * 0.62,
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(w * 0.62, h * 0.06),
              child: Transform.rotate(
                angle: 0.14,
                child: _Arch(
                  image: AppImages.categoryFoal,
                  width: w * 0.85,
                  height: h * 0.62,
                ),
              ),
            ),
            _Arch(image: AppImages.categorySwiss, width: w, height: h * 0.74),
            Positioned(bottom: h * 0.02, child: const _GoldDots()),
          ],
        );
      },
    );
  }
}

/// 2: قوس كبير + دوائر الألوان + الأطوال.
class _ColorsIllustration extends StatelessWidget {
  const _ColorsIllustration();

  static const _swatches = [
    Color(0xFFF3E4EB),
    Color(0xFF1F5C6B),
    Color(0xFFD9A21B),
    Color(0xFF3B2F6B),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        return Stack(
          alignment: Alignment.center,
          children: [
            _Backdrop(size: h * 0.92),
            Positioned(
              top: h * 0.02,
              child: _Arch(
                image: AppImages.promoChiffon,
                width: h * 0.44,
                height: h * 0.66,
              ),
            ),
            Positioned(
              bottom: h * 0.12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (i, color) in _swatches.indexed)
                      Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == 1 ? AppColors.textDark : AppColors.border,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (i, size) in [
                    '4 م'.tr,
                    '4.5 م'.tr,
                    '5 م'.tr,
                  ].indexed)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: i == 1 ? AppColors.primarySoft : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: i == 1 ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        size.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: i == 1
                              ? AppColors.primary
                              : AppColors.textDark,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 3: شاحنة التوصيل + مزايا حولها.
class _DeliveryIllustration extends StatelessWidget {
  const _DeliveryIllustration();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final circle = h * 0.56;
        return Stack(
          alignment: Alignment.center,
          children: [
            _Backdrop(size: h * 0.92),
            Container(
              width: circle,
              height: circle,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/patterns/plum_weave_tile_soft.png',
                  ),
                  repeat: ImageRepeat.repeat,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              padding: EdgeInsets.all(circle * 0.24),
              child: Image.asset('assets/icons/truck.png', color: Colors.white),
            ),
            Positioned(
              top: h * 0.08,
              right: 0,
              child: _Badge(
                icon: 'assets/icons/cash.png',
                label: 'الدفع عند الاستلام'.tr,
              ),
            ),
            Positioned(
              bottom: h * 0.14,
              left: 0,
              child: _Badge(
                icon: 'assets/icons/clock.png',
                label: 'توصيل سريع'.tr,
              ),
            ),
            Positioned(
              bottom: h * 0.02,
              right: h * 0.08,
              child: _Badge(
                icon: 'assets/icons/check.png',
                label: 'إرجاع سهل'.tr,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String icon;
  final String label;

  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageIcon(AssetImage(icon), size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

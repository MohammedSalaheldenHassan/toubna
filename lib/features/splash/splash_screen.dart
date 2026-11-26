import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/features/splash/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // الشعار بنفس مقاس شاشة النظام (112) عشان الانتقال يكون بدون قفزة
    final wordmarkWidth = (size.width * 0.5).clamp(160.0, 240.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.primary,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // النقشة تظهر تدريجيًا فوق اللون السادة لشاشة النظام
            FadeTransition(
              opacity: controller.logoFade,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/patterns/plum_weave_tile_soft.png',
                    ),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
            // توهج خفيف في المنتصف يعطي عمق
            FadeTransition(
              opacity: controller.logoFade,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.75,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: controller.logoScale,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo/logo_mark.png',
                        width: 112,
                      ),
                    ),
                  ),
                  // المساحة تكبر تدريجيًا فيرتفع الشعار بنعومة لمكانه
                  SizeTransition(
                    sizeFactor: controller.wordmarkFade,
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: FadeTransition(
                        opacity: controller.wordmarkFade,
                        child: SlideTransition(
                          position: controller.wordmarkSlide,
                          child: Image.asset(
                            'assets/images/logo/wordmark_white.png',
                            width: wordmarkWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.paddingOf(context).bottom + 48,
              child: FadeTransition(
                opacity: controller.loaderFade,
                child: const Center(child: _DotsLoader()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ثلاث نقاط ذهبية متتابعة — نفس نقاط الشعار.
class _DotsLoader extends StatefulWidget {
  const _DotsLoader();

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: List.generate(3, (i) {
        final start = i * 0.2;
        final pulse =
            TweenSequence([
              TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 1),
              TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
            ]).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(start, start + 0.6, curve: Curves.easeInOut),
              ),
            );
        return FadeTransition(
          opacity: pulse,
          child: ScaleTransition(
            scale: pulse,
            child: Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}

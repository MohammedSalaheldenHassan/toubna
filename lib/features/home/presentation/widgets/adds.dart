import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:get/get.dart';
import 'package:toubna/features/home/presentation/controllers/home_controller.dart';

/// بانر العروض: نفس تصميم البانر الأصلي، بقى شرائح تتقلب تلقائيًا.
class Adds extends StatefulWidget {
  const Adds({super.key});

  @override
  State<Adds> createState() => _AddsState();
}

class _AddsState extends State<Adds> {
  static const _interval = Duration(seconds: 5);

  final HomeController controller = Get.find<HomeController>();
  final PageController _pageController = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restartTimer();
  }

  // التقليب التلقائي يقف لو الحركة مقفولة في إعدادات الجهاز
  void _restartTimer() {
    _timer?.cancel();
    if (MediaQuery.disableAnimationsOf(context)) return;
    _timer = Timer.periodic(_interval, (_) => _next());
  }

  void _next() {
    // ما نقلّب لو الصفحة مش ظاهرة (تبويب تاني أو صفحة فوقها)
    final visible =
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    if (!visible || !_pageController.hasClients) return;
    final next = (_page + 1) % controller.promos.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promos = controller.promos;
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: promos.length,
            onPageChanged: (i) {
              setState(() => _page = i);
              _restartTimer(); // لو المستخدمة قلّبت بإيدها نبدأ العد من جديد
            },
            itemBuilder: (context, i) => _PromoCard(
              slide: promos[i],
              onTap: () => controller.openCategory(promos[i].categoryId),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(promos.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xff7A1F4B)
                    : const Color(0xFFD9B9C8),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  final PromoSlide slide;
  final VoidCallback onTap;

  const _PromoCard({required this.slide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: slide.color,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                // FittedBox يصغّر المحتوى على الشاشات الضيقة بدل ما يطلع برا الكارت
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _pill(slide.badge, const Color(0xffF2C14E), Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        slide.title,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        slide.subtitle,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _pill(slide.cta, Colors.white, slide.color),
                    ],
                  ),
                ),
              ),
            ),
            AppImage(slide.image, height: 180, width: 148),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: background,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

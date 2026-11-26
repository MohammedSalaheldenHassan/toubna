import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// تأثير اللمعان أثناء التحميل.
///
/// [Shimmer] واحد يلف الصفحة (أو الجزء اللي بيتحمّل)، وجواه أي عدد من
/// [Bone]. كل العظام بتلمع مع بعض كأنها سطح واحد، والموجة تمشي من اليمين
/// لليسار في الواجهة العربية. لو الحركة مقفولة في إعدادات الجهاز بتظهر
/// العظام ثابتة.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  static ShimmerState? of(BuildContext context) =>
      context.findAncestorStateOfType<ShimmerState>();

  @override
  State<Shimmer> createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  static const base = Color(0xFFF1E7EC);
  static const highlight = Color(0xFFFCF8FA);

  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
  );
  bool _animate = true;
  bool _rtl = true;
  Size _screen = Size.zero;

  Listenable get changes => _controller;
  bool get animate => _animate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // نحفظها هنا لأن الرسم (paint) ما ينفع يقرأ من الـ context
    _animate = !MediaQuery.disableAnimationsOf(context);
    _rtl = Directionality.of(context) == TextDirection.rtl;
    _screen = MediaQuery.sizeOf(context);
    if (_animate && !_controller.isAnimating) {
      _controller.repeat(
        min: -0.5,
        max: 1.5,
        period: const Duration(milliseconds: 1300),
      );
    } else if (!_animate) {
      _controller.stop();
    }
  }

  /// التدرّج بإحداثيات الشاشة كلها، عشان كل العظام تلمع مع بعض
  /// (حتى لو الـ Shimmer ملفوف حول Sliver).
  LinearGradient get gradient {
    final t = _rtl ? 1 - _controller.value : _controller.value;
    return LinearGradient(
      begin: const Alignment(-1, -0.3),
      end: const Alignment(1, 0.3),
      colors: const [base, highlight, base],
      stops: const [0.1, 0.3, 0.4],
      transform: _SlidingGradientTransform(t),
    );
  }

  Size get screenSize => _screen;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SlidingGradientTransform extends GradientTransform {
  final double percent;

  const _SlidingGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0, 0);
}

/// "عظمة" مكان محتوى لسه بيتحمّل (صورة، سطر نص، دائرة...).
class Bone extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final bool circle;

  const Bone({super.key, this.width, this.height, this.radius = 12})
    : circle = false;

  /// سطر نص.
  const Bone.line({super.key, this.width, this.height = 12})
    : radius = 6,
      circle = false;

  const Bone.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = 0,
      circle = true;

  @override
  Widget build(BuildContext context) {
    final shimmer = Shimmer.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _BonePainter(
            shimmer: shimmer,
            boneContext: context,
            radius: radius,
            circle: circle,
          ),
        ),
      ),
    );
  }
}

class _BonePainter extends CustomPainter {
  final ShimmerState? shimmer;
  final BuildContext boneContext;
  final double radius;
  final bool circle;

  _BonePainter({
    required this.shimmer,
    required this.boneContext,
    required this.radius,
    required this.circle,
  }) : super(repaint: shimmer?.changes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ShimmerState.base;
    final s = shimmer;
    final box = boneContext.findRenderObject();
    if (s != null &&
        s.mounted &&
        s.animate &&
        box is RenderBox &&
        box.attached) {
      final offset = box.localToGlobal(Offset.zero);
      final screen = s.screenSize;
      paint.shader = s.gradient.createShader(
        Rect.fromLTWH(-offset.dx, -offset.dy, screen.width, screen.height),
      );
    }
    final rect = Offset.zero & size;
    if (circle) {
      canvas.drawOval(rect, paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BonePainter old) =>
      old.shimmer != shimmer || old.radius != radius || old.circle != circle;
}

/// كارت أبيض بإطار (زي كروت التطبيق) يحتوي عظام.
class SkeletonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double? height;

  const SkeletonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 18,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFEADFE3)),
      ),
      child: child,
    );
  }
}

/// تبديل ناعم بين الهيكل والمحتوى الحقيقي.
class LoadingSwitcher extends StatelessWidget {
  final bool loading;
  final Widget skeleton;
  final Widget child;

  const LoadingSwitcher({
    super.key,
    required this.loading,
    required this.skeleton,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      child: loading
          ? Semantics(
              key: const ValueKey('skeleton'),
              label: 'جاري التحميل'.tr,
              liveRegion: true,
              child: ExcludeSemantics(child: skeleton),
            )
          : KeyedSubtree(key: const ValueKey('content'), child: child),
    );
  }
}

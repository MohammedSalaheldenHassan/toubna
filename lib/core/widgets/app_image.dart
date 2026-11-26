import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/shimmer.dart';

/// صورة محتوى (منتج، قسم، عرض) من الـ assets أو من رابط (API).
///
/// - بتظهر تدريجيًا (fade) فوق لون هادي بنفس لون عظام التحميل.
/// - الروابط بتتخزّن على الجهاز (cache) عشان ما تتحمّل كل مرة.
/// - لو الصورة فشلت بتظهر أيقونة بدل مساحة فاضية.
class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// صور التياب طولية والعارضة فوق، فبنقصّ أقرب للأعلى عشان الوش والطرحة
  /// يظهروا بدل نص الصورة بس.
  final Alignment alignment;

  const AppImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = const Alignment(0, -0.4),
  });

  static bool isNetwork(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  /// للأماكن اللي محتاجة ImageProvider (مثلاً DecorationImage).
  static ImageProvider provider(String path) => isNetwork(path)
      ? CachedNetworkImageProvider(path)
      : AssetImage(path) as ImageProvider;

  @override
  Widget build(BuildContext context) {
    if (isNetwork(path)) {
      return CachedNetworkImage(
        imageUrl: path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (_, _) => _placeholder(),
        errorWidget: (_, _, _) => _error(),
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(child: _placeholder()),
            AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: child,
            ),
          ],
        );
      },
      errorBuilder: (_, _, _) => _error(),
    );
  }

  Widget _placeholder() => SizedBox(
    width: width,
    height: height,
    child: const ColoredBox(color: ShimmerState.base),
  );

  Widget _error() => Container(
    width: width,
    height: height,
    color: ShimmerState.base,
    alignment: Alignment.center,
    child: const Icon(Icons.image_outlined, color: Color(0xFFB98AA0)),
  );
}

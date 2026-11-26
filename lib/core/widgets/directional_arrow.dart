import 'package:flutter/material.dart';

/// سهم الرجوع / سهم "التالي" بأيقونات الهوية، بيتقلب حسب اتجاه اللغة
/// (عربي RTL أو إنجليزي LTR).
class DirectionalArrow extends StatelessWidget {
  /// true = رجوع، false = التالي (مثلاً سهم آخر الصف في القوائم).
  final bool back;

  /// true = يتلوّن زي الأيقونة (ImageIcon)، false = صورة بلونها الأصلي.
  final bool icon;
  final double? size;
  final Color? color;

  const DirectionalArrow({
    super.key,
    required this.back,
    this.icon = false,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // back_rtl يشاور يمين (رجوع في العربي)، back_ltr يشاور شمال
    final pointsRight = back ? rtl : !rtl;
    final path = pointsRight
        ? 'assets/icons/back_rtl.png'
        : 'assets/icons/back_ltr.png';
    if (icon) {
      return ImageIcon(AssetImage(path), size: size, color: color);
    }
    return Image.asset(path, width: size, height: size, color: color);
  }
}

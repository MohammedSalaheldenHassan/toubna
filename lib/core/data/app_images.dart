import 'dart:ui' show Color;

/// صورة توب حقيقية مع القسم واللون اللي بتمثله.
class ToubPhoto {
  final String path;
  final String categoryId;
  final String colorName;
  final Color swatch;

  const ToubPhoto(this.path, this.categoryId, this.colorName, this.swatch);
}

/// كل صور المحتوى في التطبيق في مكان واحد.
///
/// صور التياب الحقيقية في `assets/images/products/` (18 صورة) ومقسّمة على
/// الأقسام حسب نوع القماش. لتغيير أي صورة: غيّري المسار هنا بس.
///
/// بعد الربط بالـ API، صور المنتجات بتجي روابط (https://...) و[AppImage]
/// بيعرضها ويخزّنها مؤقتًا تلقائيًا.
abstract final class AppImages {
  static const _products = 'assets/images/products';
  static const _fabrics = 'assets/images/fabrics';

  /// صور التياب الحقيقية، كل صورة في قسمها ومعاها اسم لونها.
  static const toubPhotos = [
    // سويسري
    ToubPhoto('$_products/2.jpeg', 'swiss', 'أصفر وبنفسجي', Color(0xFFD9B44A)),
    ToubPhoto('$_products/5.jpeg', 'swiss', 'أصفر منقّط', Color(0xFFF2C230)),
    ToubPhoto('$_products/18.jpeg', 'swiss', 'ذهبي مزهّر', Color(0xFFC9A24A)),
    // فوال
    ToubPhoto('$_products/11.jpeg', 'foal', 'مربعات ملوّنة', Color(0xFFD6603C)),
    ToubPhoto('$_products/6.jpeg', 'foal', 'برتقالي ورمادي', Color(0xFFD9822B)),
    ToubPhoto('$_products/12.jpeg', 'foal', 'رمادي هندسي', Color(0xFF8A8A8A)),
    // قرمصيص (أعراس)
    ToubPhoto(
      '$_products/images.jpeg',
      'garmasis',
      'أخضر مطرّز بالذهبي',
      Color(0xFF1F5A44),
    ),
    ToubPhoto(
      '$_products/16.jpeg',
      'garmasis',
      'أصفر هندسي',
      Color(0xFFD8B33A),
    ),
    // شيفون
    ToubPhoto('$_products/13.jpeg', 'chiffon', 'وردي وأزرق', Color(0xFFC86A9A)),
    ToubPhoto(
      '$_products/7.jpeg',
      'chiffon',
      'بنفسجي متدرّج',
      Color(0xFF4B2E4A),
    ),
    ToubPhoto('$_products/8.jpeg', 'chiffon', 'كحلي متدرّج', Color(0xFF2B3550)),
    ToubPhoto('$_products/9.jpeg', 'chiffon', 'بني وفيروزي', Color(0xFF7A3E2A)),
    ToubPhoto('$_products/1.jpeg', 'chiffon', 'رمادي مموّج', Color(0xFF8C7F73)),
    // مشغول
    ToubPhoto(
      '$_products/3.jpeg',
      'mashghool',
      'أسود بذهبي',
      Color(0xFF1E1A1A),
    ),
    ToubPhoto(
      '$_products/14.jpeg',
      'mashghool',
      'كحلي مشغول',
      Color(0xFF1F2638),
    ),
    // حرير
    ToubPhoto(
      '$_products/17.jpeg',
      'silk',
      'ذهبي بورد بنفسجي',
      Color(0xFFD4A84A),
    ),
    ToubPhoto('$_products/10.jpeg', 'silk', 'بنفسجي مورّد', Color(0xFF7B4FA0)),
    ToubPhoto('$_products/15.jpeg', 'silk', 'أزرق مورّد', Color(0xFF3E5BA0)),
  ];

  static List<ToubPhoto> photosOf(String categoryId) => [
    for (final p in toubPhotos)
      if (p.categoryId == categoryId) p,
  ];

  // ---------- أغلفة الأقسام (أول صورة في كل قسم) ----------
  static const categorySwiss = '$_products/2.jpeg';
  static const categoryFoal = '$_products/11.jpeg';
  static const categoryGarmasis = '$_products/images.jpeg';
  static const categoryChiffon = '$_products/13.jpeg';
  static const categoryMashghool = '$_products/3.jpeg';
  static const categorySilk = '$_products/17.jpeg';

  /// ما في صور إكسسوارات لسه — نقشة مؤقتة.
  static const categoryAccessories = '$_fabrics/swiss_plum_dots.png';

  // ---------- بانرات العروض في الرئيسية ----------
  static const promoWedding = categoryGarmasis;
  static const promoChiffon = '$_products/7.jpeg';
  static const promoFreeDelivery = '$_products/18.jpeg';

  // ---------- تسوقي حسب المناسبة ----------
  static const occasionWedding = '$_products/16.jpeg';
  static const occasionEid = categorySilk;
  static const occasionWork = '$_products/12.jpeg';
  static const occasionVisits = '$_products/9.jpeg';

  // ---------- ألوان احتياطية (للمنتجات اللي ما عندها صور، زي الإكسسوارات) ----------
  static const colorPink = '$_fabrics/swiss_pink_dots.png';
  static const colorTeal = '$_fabrics/teal_dots.png';
  static const colorGold = '$_fabrics/gold_dots.png';
  static const colorIndigo = '$_fabrics/indigo_gold_dots.png';

  // ---------- زخرفة (مش منتج) ----------
  /// دائرة السلة الفاضية: نقشة ناعمة زي التصميم الأصلي.
  static const emptyCart = '$_fabrics/chiffon_blush_dots.png';

  /// كل صور المحتوى (للاختبار إنها موجودة فعلًا في الـ assets).
  static final all = <String>{
    for (final p in toubPhotos) p.path,
    categoryAccessories,
    colorPink,
    colorTeal,
    colorGold,
    colorIndigo,
    emptyCart,
  }.toList();
}

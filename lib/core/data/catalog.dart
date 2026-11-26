import 'package:get/get.dart';
import 'package:toubna/core/data/app_images.dart';

/// بيانات تجريبية للأقسام والمنتجات — لاحقًا تتبدل بنداءات الـ API.
///
/// النصوص بتتخزّن بالعربي (مفتاح الترجمة) وبتتترجم وقت العرض، عشان
/// تبديل اللغة يغيّرها فورًا.
class Category {
  final String id;
  final String nameKey;
  final String image;
  final int productCount;

  /// نوع القماش اللي يظهر تحت اسم المنتج (مثلاً: "سويسري").
  final String kindKey;
  final int basePrice;

  const Category({
    required this.id,
    required String name,
    required this.image,
    required this.productCount,
    required String kind,
    required this.basePrice,
  }) : nameKey = name,
       kindKey = kind;

  String get name => nameKey.tr;
  String get kind => kindKey.tr;
  String get countText => '@count منتج'.trParams({'count': '$productCount'});
}

class Product {
  final String id;
  final String categoryId;
  final String nameKey;
  final String kindKey;
  final int price;
  final String image;
  final bool isNew;
  final int sales;

  const Product({
    required this.id,
    required this.categoryId,
    required String name,
    required String kind,
    required this.price,
    required this.image,
    required this.isNew,
    required this.sales,
  }) : nameKey = name,
       kindKey = kind;

  String get name => nameKey.tr;
  String get kind => kindKey.tr;

  String get priceText => formatPrice(price);

  /// السعر قبل الخصم (للمنتجات الأكثر مبيعًا عليها عرض) — تجريبي.
  int? get compareAtPrice =>
      sales >= 60 ? ((price * 1.18) / 500).round() * 500 : null;
}

/// 85000 → "85,000 ج.س" / "85,000 SDG"
String formatPrice(int price) {
  final digits = price.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '@amount ج.س'.trParams({'amount': '$buffer'});
}

abstract final class Catalog {
  static const swiss = Category(
    id: 'swiss',
    name: 'توب سويسري',
    image: AppImages.categorySwiss,
    productCount: 48,
    kind: 'سويسري',
    basePrice: 70000,
  );

  /// الأقسام المعروضة في شبكة صفحة الأقسام (السويسري ظاهر في البانر).
  static const gridCategories = [
    Category(
      id: 'foal',
      name: 'فوال',
      image: AppImages.categoryFoal,
      productCount: 41,
      kind: 'فوال',
      basePrice: 35000,
    ),
    Category(
      id: 'garmasis',
      name: 'قرمصيص',
      image: AppImages.categoryGarmasis,
      productCount: 36,
      kind: 'قرمصيص',
      basePrice: 90000,
    ),
    Category(
      id: 'chiffon',
      name: 'شيفون',
      image: AppImages.categoryChiffon,
      productCount: 29,
      kind: 'شيفون',
      basePrice: 45000,
    ),
    Category(
      id: 'mashghool',
      name: 'مشغول',
      image: AppImages.categoryMashghool,
      productCount: 22,
      kind: 'مشغول',
      basePrice: 100000,
    ),
    Category(
      id: 'silk',
      name: 'حرير',
      image: AppImages.categorySilk,
      productCount: 18,
      kind: 'حرير',
      basePrice: 80000,
    ),
    Category(
      id: 'accessories',
      name: 'إكسسوارات',
      image: AppImages.categoryAccessories,
      productCount: 15,
      kind: 'إكسسوار',
      basePrice: 8000,
    ),
  ];

  static const all = [swiss, ...gridCategories];

  static Category byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => swiss);

  static const names = [
    'وردة النيل',
    'نسمة كسلا',
    'نجمة الليل',
    'زهرة الخرطوم',
    'ليالي سنار',
    'قمر توتي',
    'نسيم البحر',
    'غيمة الصباح',
    'ندى الفجر',
    'أصيلة',
  ];
  static const variants = ['سادة', 'مطرّز', 'بنقوش', 'بخيوط ذهبية'];

  /// منتجات القسم (نفس العدد المكتوب على كارت القسم).
  static List<Product> productsOf(Category category) {
    // صور التياب الحقيقية للقسم بالتناوب (الإكسسوارات لسه بدون صور)
    final photos = AppImages.photosOf(category.id);
    return List.generate(category.productCount, (i) {
      final steps = (i * 7) % 9; // تنويع ثابت للأسعار
      return Product(
        id: '${category.id}-$i',
        categoryId: category.id,
        name: names[i % names.length],
        kind: '${category.kindKey} ${variants[i % variants.length]}',
        price: category.basePrice + steps * 2500,
        image: photos.isEmpty ? category.image : photos[i % photos.length].path,
        isNew: i % 5 == 0,
        sales: (i * 37 + category.id.length * 11) % 100,
      );
    });
  }
}

/// استعلامات جاهزة على كل المنتجات.
abstract final class Products {
  static final List<Product> all = [
    for (final c in Catalog.all) ...Catalog.productsOf(c),
  ];

  static List<Product> bestSellers(int count) => ([
    ...all,
  ]..sort((a, b) => b.sales.compareTo(a.sales))).take(count).toList();

  /// منتج جديد واحد من كل قسم بالتناوب، عشان القائمة تكون متنوعة.
  static final List<Product> newArrivals = () {
    final perCategory = [
      for (final c in Catalog.all)
        Catalog.productsOf(c).where((p) => p.isNew).toList(),
    ];
    final result = <Product>[];
    for (var round = 0; result.length < all.length; round++) {
      var added = false;
      for (final list in perCategory) {
        if (round < list.length) {
          result.add(list[round]);
          added = true;
        }
      }
      if (!added) break;
    }
    return result;
  }();

  static Product? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// بحث بالاسم أو النوع، مع توحيد أشكال الحروف (أ/إ/آ، ة/ه، ى/ي).
  static List<Product> search(String query) {
    final q = normalizeArabic(query.toLowerCase());
    if (q.isEmpty) return all;
    final words = q.split(' ').where((w) => w.isNotEmpty);
    return [
      for (final p in all)
        // نبحث في النص العربي والمترجم (عشان البحث بالإنجليزي يشتغل)
        if (words.every(
          normalizeArabic(
            '${p.nameKey} ${p.kindKey} ${p.name} ${p.kind}'.toLowerCase(),
          ).contains,
        ))
          p,
    ];
  }
}

String normalizeArabic(String text) => text
    .trim()
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ة', 'ه')
    .replaceAll('ى', 'ي')
    .replaceAll(RegExp('[ً-ْ]'), '') // التشكيل
    .replaceAll(RegExp(r'\s+'), ' ');

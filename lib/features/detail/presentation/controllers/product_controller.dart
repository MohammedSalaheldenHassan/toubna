import 'package:toubna/core/data/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/services/favorites_controller.dart';
import 'package:toubna/core/utils/simulated_loading.dart';
import 'package:toubna/features/cart/data/cart_item.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';

/// يفتح بـ Get.toNamed(AppRoutes.product, arguments: product.id)
class ProductController extends GetxController with LoadingState {
  late final Product product;
  final _favorites = Get.find<FavoritesController>();

  /// الألوان المتاحة: أول لون صورة المنتج نفسه، وبعده باقي صور تياب نفس
  /// القسم (كل صورة لون). المنتجات بدون صور تاخد ألوان احتياطية.
  late final List<Map<String, dynamic>> colors = _buildColors();

  List<Map<String, dynamic>> _buildColors() {
    final photos = AppImages.photosOf(product.categoryId);
    if (photos.isEmpty) {
      return [
        {
          'name': 'وردي بنقوش عنابية',
          'color': const Color(0xFFF3E4EB),
          'image': product.image,
        },
        {
          'name': 'فيروزي',
          'color': const Color(0xFF1F5C6B),
          'image': AppImages.colorTeal,
        },
        {
          'name': 'ذهبي',
          'color': const Color(0xFFD9A21B),
          'image': AppImages.colorGold,
        },
        {
          'name': 'نيلي',
          'color': const Color(0xFF3B2F6B),
          'image': AppImages.colorIndigo,
        },
      ];
    }
    final own = photos.firstWhere(
      (p) => p.path == product.image,
      orElse: () => photos.first,
    );
    return [
      for (final p in [own, ...photos.where((p) => p != own)])
        {'name': p.colorName, 'color': p.swatch, 'image': p.path},
    ];
  }

  // وصف تجريبي حسب القسم — لاحقًا يجي مع المنتج من الـ API
  static const _descriptions = {
    'swiss':
        'قماش سويسري قطني ناعم ومريح، بتطريز يدوي لزهور على الأطراف. مناسب للمناسبات النهارية والزيارات.',
    'foal':
        'فوال خفيف وعملي بطبعات مميزة، مريح للبس اليومي والدوام وما بيتكرمش بسهولة.',
    'garmasis':
        'قرمصيص فاخر بتطريز وخرز لامع، التوب التقليدي للعروس وليالي الأعراس.',
    'chiffon':
        'شيفون ناعم وخفيف بألوان متدرّجة، انسيابي ومناسب للزيارات والمناسبات.',
    'mashghool':
        'توب مشغول يدويًا بخيوط ذهبية وتفاصيل دقيقة، لإطلالة راقية في المناسبات الكبيرة.',
    'silk': 'حرير لامع بنقوش ورود، ملمس ناعم وإطلالة فخمة للعيد والمناسبات.',
    'accessories': 'إكسسوارات تكمّل إطلالة التوب: دبابيس، شنط وطرح.',
  };

  String get description =>
      (_descriptions[product.categoryId] ?? _descriptions['swiss']!).tr;

  final List<String> sizes = const ['قياسي 4.5 م', 'طويل 5 م', 'قصير 4 م'];
  final int stock = 4;

  final pageController = PageController();
  final selectedColor = 0.obs;
  final selectedSize = 0.obs;
  final qty = 1.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments is String ? Get.arguments as String : '';
    product = Products.byId(id) ?? Products.all.first;
    // هنا لاحقًا: load(() => api.fetchProduct(id))
    load(null, AppConfig.quickLatency);
  }

  bool get canIncrease => qty.value < stock;
  bool get canDecrease => qty.value > 1;

  void selectColor(int i) {
    selectedColor.value = i;
    pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void onPageChanged(int i) => selectedColor.value = i;

  void selectSize(int i) => selectedSize.value = i;

  void increase() {
    if (canIncrease) qty.value++;
  }

  void decrease() {
    if (canDecrease) qty.value--;
  }

  bool get isFavorite => _favorites.isFavorite(product);

  void toggleFavorite() => _favorites.toggle(product);

  void addToCart() {
    final color = colors[selectedColor.value];
    final size = sizes[selectedSize.value];
    // نفس المنتج بلون/طول مختلف = سطر منفصل في السلة
    Get.find<CartController>().add(
      CartItem(
        id: '${product.id}-${selectedColor.value}-${selectedSize.value}',
        name: product.nameKey,
        kind: product.kindKey,
        image: color['image'],
        price: product.price,
        qty: qty.value,
        maxQty: stock,
        variantKeys: [color['name'] as String, size],
      ),
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

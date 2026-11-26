import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/utils/simulated_loading.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/favorites_controller.dart';
import 'package:toubna/features/categories/presentation/controllers/category_products_controller.dart';

/// يفتح بـ Get.toNamed(AppRoutes.search, arguments: {'focus': true})
/// بدون focus = "عرض كل المنتجات".
class ProductSearchController extends GetxController with LoadingState {
  static const suggestions = [
    'سويسري',
    'قرمصيص',
    'شيفون',
    'مطرّز',
    'ذهبي',
    'حرير',
  ];

  // آخر عمليات البحث (في الذاكرة لحد ما يتقفل التطبيق)
  static final _recent = <String>[];
  static const _maxRecent = 6;

  final textController = TextEditingController();
  final focusNode = FocusNode();
  final query = ''.obs;
  final sort = ProductSort.bestSelling.obs;
  final recent = <String>[].obs;
  final _favorites = Get.find<FavoritesController>();

  late final bool autofocus;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    autofocus = args is Map && args['focus'] == true;
    recent.assignAll(_recent);
    // نستنى المستخدمة توقف كتابة قبل ما نفلتر
    debounce(
      _typed,
      (String value) => _runSearch(value),
      time: const Duration(milliseconds: 250),
    );
    load(null, AppConfig.quickLatency);
  }

  /// البحث كأنه طلب للسيرفر: هيكل لامع قصير وبعدها النتائج.
  Future<void> _runSearch(String value) async {
    if (value == query.value) return;
    await load(() async {
      // هنا لاحقًا: await api.search(value)
      await Future.delayed(const Duration(milliseconds: 350));
      query.value = value;
    });
  }

  final _typed = ''.obs;

  void onChanged(String value) => _typed.value = value;

  List<Product> get results {
    final list = Products.search(query.value);
    final sorted = [...list];
    switch (sort.value) {
      case ProductSort.bestSelling:
        sorted.sort((a, b) => b.sales.compareTo(a.sales));
      case ProductSort.newest:
        sorted.sort((a, b) => a.isNew == b.isNew ? 0 : (a.isNew ? -1 : 1));
      case ProductSort.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
    }
    return sorted;
  }

  /// من الاقتراحات أو البحث السابق أو زر البحث في الكيبورد.
  void searchFor(String value) {
    final text = value.trim();
    textController.text = text;
    textController.selection = TextSelection.collapsed(offset: text.length);
    _typed.value = text;
    query.value = text;
    _remember(text);
    focusNode.unfocus();
  }

  void clear() {
    textController.clear();
    _typed.value = '';
    query.value = '';
    focusNode.requestFocus();
  }

  void clearRecent() {
    _recent.clear();
    recent.clear();
  }

  void _remember(String text) {
    if (text.isEmpty) return;
    _recent
      ..remove(text)
      ..insert(0, text);
    if (_recent.length > _maxRecent) _recent.removeLast();
    recent.assignAll(_recent);
  }

  void selectSort(ProductSort value) => sort.value = value;

  bool isFavorite(Product p) => _favorites.isFavorite(p);

  void toggleFavorite(Product p) => _favorites.toggle(p);

  void openProduct(Product p) {
    _remember(query.value);
    Get.toNamed(AppRoutes.product, arguments: p.id);
  }

  @override
  void onClose() {
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}

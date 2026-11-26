import 'package:get/get.dart';
import 'package:toubna/core/utils/simulated_loading.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/favorites_controller.dart';

enum ProductSort {
  bestSelling('الأكثر مبيعًا'),
  newest('الأحدث'),
  priceLow('السعر: الأقل'),
  priceHigh('السعر: الأعلى');

  const ProductSort(this.labelKey);
  final String labelKey;

  String get label => labelKey.tr;
}

/// يفتح بـ Get.toNamed(AppRoutes.category, arguments: category.id)
class CategoryProductsController extends GetxController with LoadingState {
  late final Category category;
  late final List<Product> _products;

  final sort = ProductSort.bestSelling.obs;
  final newOnly = false.obs;
  final _favorites = Get.find<FavoritesController>();

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments is String ? Get.arguments as String : '';
    category = Catalog.byId(id);
    _products = Catalog.productsOf(category);
    load(); // هنا لاحقًا: load(() => api.fetchCategory(id))
  }

  /// المنتجات بعد الفلترة والترتيب.
  List<Product> get products {
    final list = [
      for (final p in _products)
        if (!newOnly.value || p.isNew) p,
    ];
    switch (sort.value) {
      case ProductSort.bestSelling:
        list.sort((a, b) => b.sales.compareTo(a.sales));
      case ProductSort.newest:
        // الجديد أولًا، وبعدها حسب ترتيب الإضافة
        list.sort((a, b) {
          if (a.isNew != b.isNew) return a.isNew ? -1 : 1;
          return _products.indexOf(a).compareTo(_products.indexOf(b));
        });
      case ProductSort.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
    }
    return list;
  }

  void selectSort(ProductSort value) => sort.value = value;

  void toggleNewOnly() => newOnly.toggle();

  bool isFavorite(Product p) => _favorites.isFavorite(p);

  void toggleFavorite(Product p) => _favorites.toggle(p);

  void openProduct(Product p) =>
      Get.toNamed(AppRoutes.product, arguments: p.id);
}

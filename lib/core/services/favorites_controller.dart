import 'package:get/get.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/services/app_storage.dart';

/// المفضلة على مستوى التطبيق كله (الرئيسية، الأقسام، البحث، صفحة المفضلة).
/// يتسجّل مرة واحدة في initialBinding ويفضل طول عمر التطبيق، وبيتحفظ على
/// الجهاز عشان ما يضيع لما التطبيق يتقفل.
class FavoritesController extends GetxController {
  // هنا لاحقًا: تتزامن مع حساب المستخدمة في الـ API
  final ids = <String>{}.obs;

  /// بيكتمل بعد قراءة المفضلة المحفوظة.
  late final Future<void> ready = _restore();

  @override
  void onInit() {
    super.onInit();
    ready;
  }

  Future<void> _restore() async {
    final saved = await AppStorage.readJson(AppStorage.favoritesKey);
    if (saved is List) {
      // نتجاهل أي منتج اتحذف من الكتالوج
      ids.addAll([
        for (final id in saved)
          if (id is String && Products.byId(id) != null) id,
      ]);
    }
    // من هنا وطالع: أي تغيير يتحفظ
    ever(
      ids,
      (_) => AppStorage.writeJson(AppStorage.favoritesKey, ids.toList()),
    );
  }

  int get count => ids.length;

  bool isFavorite(Product p) => ids.contains(p.id);

  void toggle(Product p) => isFavorite(p) ? ids.remove(p.id) : ids.add(p.id);

  List<Product> get products => [for (final id in ids) ?Products.byId(id)];

  void clear() => ids.clear();
}

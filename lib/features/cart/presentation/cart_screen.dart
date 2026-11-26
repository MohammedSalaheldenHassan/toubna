import 'package:toubna/core/data/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/i18n/plural.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/favorites_controller.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/product_card.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';
import 'package:toubna/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:toubna/features/cart/presentation/widgets/cart_summary.dart';
import 'package:toubna/features/routes/main_shell_controller.dart';

class CartScreen extends GetView<CartController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final empty = controller.isEmpty;
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: _CartHeader(),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: empty
                      ? const _EmptyCart(key: ValueKey('empty'))
                      : const _FilledCart(key: ValueKey('filled')),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: empty ? null : const CheckoutBar(),
      );
    });
  }
}

class _CartHeader extends GetView<CartController> {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "السلة".tr,
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                if (!controller.isEmpty)
                  Text(
                    itemsText(controller.count),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (!controller.isEmpty)
            TextButton.icon(
              onPressed: controller.confirmClear,
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              icon: const ImageIcon(
                AssetImage('assets/icons/trash.png'),
                size: 18,
              ),
              label: Text('تفريغ'.tr),
            ),
        ],
      ),
    );
  }
}

// ---------------- السلة فيها منتجات ----------------
class _FilledCart extends GetView<CartController> {
  const _FilledCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.items;
      return ListView(
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const FreeDeliveryCard(),
          const SizedBox(height: 14),
          for (final item in items) ...[
            CartItemCard(key: ValueKey(item.id), item: item),
            const SizedBox(height: 10),
          ],
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'اسحبي المنتج لليسار للحذف'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const CouponCard(),
          const SizedBox(height: 14),
          const CartSummaryCard(),
        ],
      );
    });
  }
}

// ---------------- السلة فاضية ----------------
class _EmptyCart extends StatelessWidget {
  const _EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<MainShellController>();
    final favorites = Get.find<FavoritesController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 30, bottom: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                // الدائرة تظهر بحركة خفيفة مع حلقة ناعمة حولها
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        image: const DecorationImage(
                          image: AssetImage(AppImages.emptyCart),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Image.asset(
                              "assets/icons/bag.png",
                              color: const Color(0xff7A1F4B),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "سلتك فاضية".tr,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "لسه ما ضفتي أي توب. تصفّحي الأقسام واختاري اللي يعجبك لمناسبتك الجاية."
                      .tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.6,
                    color: AppColors.textBody,
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  color: const Color(0xff7A1F4B),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => shell.changeTab(1),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28),
                      child: SizedBox(
                        height: 52,
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            "ابدئي التسوق".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.favorites),
                  icon: const ImageIcon(
                    AssetImage('assets/icons/heart.png'),
                    size: 20,
                  ),
                  label: Obx(
                    () => Text(
                      'عرض المفضلة (@p0)'.trParams({
                        'p0': '${favorites.count}',
                      }),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _Suggestions(),
        ],
      ),
    );
  }
}

/// "ممكن يعجبك": الأكثر مبيعًا في شريط أفقي.
class _Suggestions extends StatelessWidget {
  const _Suggestions();

  @override
  Widget build(BuildContext context) {
    final favorites = Get.find<FavoritesController>();
    final products = Products.bestSellers(6);
    final height = 184 + MediaQuery.textScalerOf(context).scale(76);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'ممكن يعجبك'.tr,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final p = products[i];
              return SizedBox(
                width: 165,
                child: Obx(
                  () => ProductCard(
                    name: p.name,
                    kind: p.kind,
                    price: p.priceText,
                    image: p.image,
                    isNew: p.isNew,
                    isFavorite: favorites.isFavorite(p),
                    onFavorite: () => favorites.toggle(p),
                    onTap: () =>
                        Get.toNamed(AppRoutes.product, arguments: p.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

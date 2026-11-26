import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/favorites_controller.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/page_header.dart';
import 'package:toubna/core/widgets/product_card.dart';

class FavScreen extends GetView<FavoritesController> {
  const FavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: "المفضلة".tr,
      child: Obx(() {
        final products = controller.products;
        if (products.isEmpty) return const _EmptyFavorites();
        return GridView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          gridDelegate: productGridDelegate(context),
          itemCount: products.length,
          itemBuilder: (context, i) {
            final p = products[i];
            return ProductCard(
              name: p.name,
              kind: p.kind,
              price: p.priceText,
              image: p.image,
              isNew: p.isNew,
              isFavorite: true,
              onFavorite: () => controller.toggle(p),
              onTap: () => Get.toNamed(AppRoutes.product, arguments: p.id),
            );
          },
        );
      }),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(26),
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icons/heart.png',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'مافي حاجة في المفضلة'.tr,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'اضغطي على القلب في أي توب عشان تحفظيه هنا.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.search),
              child: Text(
                'تصفّحي المنتجات'.tr,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

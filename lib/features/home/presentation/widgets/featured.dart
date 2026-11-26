import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/widgets/product_card.dart';
import 'package:toubna/features/home/presentation/controllers/home_controller.dart';
import 'package:toubna/features/home/presentation/widgets/section_header.dart';

class Featured extends GetView<HomeController> {
  const Featured({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'الأكثر مبيعًا'.tr,
          onSeeAll: controller.openAllProducts,
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: controller.featuredProducts.length,
          gridDelegate: productGridDelegate(context),
          itemBuilder: (context, index) {
            final p = controller.featuredProducts[index];
            return Obx(
              () => ProductCard(
                name: p.name,
                kind: p.kind,
                price: p.priceText,
                image: p.image,
                isNew: p.isNew,
                isFavorite: controller.isFavorite(p),
                onFavorite: () => controller.toggleFavorite(p),
                onTap: () => controller.openProduct(p),
              ),
            );
          },
        ),
      ],
    );
  }
}

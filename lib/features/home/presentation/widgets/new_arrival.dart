import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:get/get.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/features/home/presentation/controllers/home_controller.dart';
import 'package:toubna/features/home/presentation/widgets/section_header.dart';

class NewArrival extends GetView<HomeController> {
  const NewArrival({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: "وصل حديثًا".tr,
          onSeeAll: controller.openAllProducts,
        ),
        const SizedBox(height: 10),
        Obx(() {
          final items = controller.visibleNewArrivals;
          return Column(
            children: [
              for (final (i, p) in items.indexed) ...[
                if (i > 0) const SizedBox(height: 10),
                // العناصر الجديدة تظهر بحركة خفيفة
                TweenAnimationBuilder<double>(
                  key: ValueKey(p.id),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  builder: (context, t, child) => Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - t)),
                      child: child,
                    ),
                  ),
                  child: _NewArrivalCard(product: p, isToday: i == 0),
                ),
              ],
            ],
          );
        }),
        const SizedBox(height: 10),
        Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: controller.canLoadMore
                ? Material(
                    key: const ValueKey('more'),
                    color: const Color(0xff7A1F4B),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: controller.loadMoreNewArrivals,
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 200,
                        height: 40,
                        child: Center(
                          child: Text(
                            "عرض المزيد".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : TextButton(
                    key: const ValueKey('all'),
                    onPressed: controller.openAllProducts,
                    child: Text(
                      'تصفّحي كل المنتجات'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff7A1F4B),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _NewArrivalCard extends GetView<HomeController> {
  final Product product;
  final bool isToday;

  const _NewArrivalCard({required this.product, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xffEADFE3)),
      ),
      child: InkWell(
        onTap: () => controller.openProduct(product),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AppImage(product.image, width: 104, height: 104),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF3E4EB),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          isToday ? "وصل اليوم".tr : "جديد".tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xff7A1F4B),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      product.kind,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xff6B5E66),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        product.priceText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff7A1F4B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'أضيفي إلى السلة'.tr,
                child: Material(
                  color: const Color(0xff7A1F4B),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => controller.addToCart(product),
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          "assets/icons/plus.png",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/directional_arrow.dart';
import 'package:get/get.dart';
import 'package:toubna/core/widgets/error_state_view.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/theme/app_theme.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:toubna/core/widgets/shimmer.dart';
import 'package:toubna/features/detail/presentation/controllers/product_controller.dart';

class ProductScreen extends GetView<ProductController> {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _gallery(context),
            // اللوحة اللي بتطلع فوق الصورة بـ 24
            Transform.translate(
              offset: const Offset(0, -24),
              child: _details(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  // ---------------- معرض الصور ----------------
  Widget _gallery(BuildContext context) {
    final colors = controller.colors;
    return SizedBox(
      // 360 على الهواتف العادية، ويتناسب مع الشاشات الأصغر والأكبر
      height: (MediaQuery.sizeOf(context).height * 0.45).clamp(280.0, 460.0),
      child: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            itemCount: colors.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (_, i) =>
                AppImage(colors[i]['image'], width: double.infinity),
          ),
          // هيكل لامع فوق المعرض لحد ما المنتج يتحمّل
          Obx(
            () => controller.isLoading.value
                ? const Positioned.fill(child: Shimmer(child: Bone(radius: 0)))
                : const SizedBox.shrink(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(
                    tooltip: 'رجوع'.tr,
                    onPressed: () => Navigator.maybePop(context),
                    child: const DirectionalArrow(
                      back: true,
                      icon: true,
                      size: 22,
                      color: Color(0xFF221A22),
                    ),
                  ),
                  Obx(
                    () => _circleButton(
                      tooltip: 'المفضلة'.tr,
                      onPressed: controller.toggleFavorite,
                      child: ImageIcon(
                        AssetImage(
                          controller.isFavorite
                              ? 'assets/icons/heart_filled.png'
                              : 'assets/icons/heart.png',
                        ),
                        size: 22,
                        color: const Color(0xFF7A1F4B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // نقاط المعرض
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(colors.length, (i) {
                  final active = i == controller.selectedColor.value;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required String tooltip,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        fixedSize: const Size(44, 44),
      ),
      icon: child,
    );
  }

  // ---------------- التفاصيل ----------------
  Widget _details() {
    return Obx(
      () => controller.hasError
          ? ErrorStateView(
              error: controller.error.value!,
              onRetry: controller.retry,
              compact: true,
            )
          : controller.isLoading.value
          ? const _DetailsSkeleton()
          : _detailsContent(),
    );
  }

  Widget _detailsContent() {
    final colors = controller.colors;
    final sizes = controller.sizes;
    final stock = controller.stock;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: const BoxDecoration(
        color: Color(0xFFFBF7F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الاسم والسعر
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.product.kind,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B5E66),
                      ),
                    ),
                    Text(
                      controller.product.name,
                      style: const TextStyle(
                        fontFamily: 'ReemKufi',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF221A22),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    controller.product.priceText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A1F4B),
                    ),
                  ),
                  if (controller.product.compareAtPrice case final was?)
                    Text(
                      formatPrice(was),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B5E66),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // حالة التوفر
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: stock > 0
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF9A3412),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                stock > 0
                    ? 'متوفر — تبقّى @p0 قطع'.trParams({'p0': '$stock'})
                    : 'غير متوفر حاليًا'.tr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: stock > 0
                      ? const Color(0xFF166534)
                      : const Color(0xFF9A3412),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // اللون
          Obx(
            () => Text.rich(
              TextSpan(
                text: 'اللون: '.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF221A22),
                ),
                children: [
                  TextSpan(
                    text:
                        (colors[controller.selectedColor.value]['name']
                                as String)
                            .tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B5E66),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              runSpacing: 12,
              children: List.generate(colors.length, (i) {
                final selected = i == controller.selectedColor.value;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: Semantics(
                    label: (colors[i]['name'] as String).tr,
                    selected: selected,
                    button: true,
                    child: GestureDetector(
                      onTap: () => controller.selectColor(i),
                      child: Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? const Color(0xFF221A22)
                              : const Color(0xFFEADFE3),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors[i]['color'],
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),

          // الطول
          Text(
            'الطول'.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF221A22),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(sizes.length, (i) {
                final selected = i == controller.selectedSize.value;
                return InkWell(
                  onTap: () => controller.selectSize(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFF3E4EB) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF7A1F4B)
                            : const Color(0xFFEADFE3),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      sizes[i].tr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? const Color(0xFF7A1F4B)
                            : const Color(0xFF221A22),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),

          // الوصف
          Text(
            controller.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.7,
              color: Color(0xFF4A3F46),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- الشريط السفلي ----------------
  Widget _bottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEADFE3))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // الكمية
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEADFE3)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Obx(
                  () => Row(
                    // ثابت: + يمين و− شمال في اللغتين (العُرف في الاتنين)
                    textDirection: TextDirection.rtl,
                    children: [
                      _qtyButton(
                        '+',
                        'زيادة الكمية'.tr,
                        controller.canIncrease ? controller.increase : null,
                      ),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${controller.qty.value}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _qtyButton(
                        '−',
                        'إنقاص الكمية'.tr,
                        controller.canDecrease ? controller.decrease : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // إضافة للسلة
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: controller.stock > 0
                        ? controller.addToCart
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A1F4B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: const ImageIcon(
                      AssetImage('assets/icons/bag.png'),
                      size: 20,
                    ),
                    label: Text('أضيفي إلى السلة'.tr),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyButton(String label, String tooltip, VoidCallback? onTap) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF3E4EB),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: onTap == null
                      ? const Color(0xFFB98AA0)
                      : const Color(0xFF7A1F4B),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget chips(int n, double w, double h, {bool circle = false}) => Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < n; i++)
          circle ? Bone.circle(size: h) : Bone(width: w, height: h),
      ],
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: const BoxDecoration(
        color: Color(0xFFFBF7F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone.line(width: 90),
                      SizedBox(height: 8),
                      Bone.line(width: 150, height: 22),
                    ],
                  ),
                ),
                Bone.line(width: 90, height: 20),
              ],
            ),
            const SizedBox(height: 18),
            const Bone.line(width: 140),
            const SizedBox(height: 18),
            const Bone.line(width: 110),
            const SizedBox(height: 10),
            chips(4, 44, 44, circle: true),
            const SizedBox(height: 18),
            const Bone.line(width: 50),
            const SizedBox(height: 10),
            chips(3, 90, 44),
            const SizedBox(height: 18),
            const Bone.line(width: double.infinity),
            const SizedBox(height: 8),
            const Bone.line(width: 220),
          ],
        ),
      ),
    );
  }
}

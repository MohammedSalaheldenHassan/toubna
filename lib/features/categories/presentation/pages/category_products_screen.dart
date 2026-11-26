import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:get/get.dart';
import 'package:toubna/core/widgets/error_state_view.dart';
import 'package:toubna/core/widgets/skeletons.dart';
import 'package:toubna/core/widgets/shimmer.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/choice_chip_button.dart';
import 'package:toubna/core/widgets/page_header.dart';
import 'package:toubna/core/widgets/product_card.dart';
import 'package:toubna/features/categories/presentation/controllers/category_products_controller.dart';

class CategoryProductsScreen extends GetView<CategoryProductsController> {
  const CategoryProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category = controller.category;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              sliver: SliverList.list(
                children: [
                  PageHeader(
                    title: category.name,
                    subtitle: category.countText,
                  ),
                  const SizedBox(height: 16),
                  const _CategoryBanner(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: _FilterBar()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 24),
              sliver: Obx(() {
                if (controller.hasError) {
                  return SliverToBoxAdapter(
                    child: ErrorStateView(
                      error: controller.error.value!,
                      onRetry: controller.retry,
                      compact: true,
                    ),
                  );
                }
                if (controller.isLoading.value) {
                  return const Shimmer(child: SliverProductGridSkeleton());
                }
                final products = controller.products;
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(child: _EmptyState());
                }
                return SliverGrid.builder(
                  gridDelegate: productGridDelegate(context),
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final p = products[i];
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// صورة القماش مع اسم القسم — بنفس روح بانر العروض في الرئيسية.
class _CategoryBanner extends GetView<CategoryProductsController> {
  const _CategoryBanner();

  @override
  Widget build(BuildContext context) {
    final category = controller.category;
    return Container(
      // 130 بالخط العادي، ويزيد مع تكبير الخط
      height: 40 + MediaQuery.textScalerOf(context).scale(90),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(category.image),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.75),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    category.countText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'اختاري توبك لمناسبتك الجاية'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط الفلترة والترتيب (يتسكرول أفقيًا على الشاشات الضيقة).
class _FilterBar extends GetView<CategoryProductsController> {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          children: [
            ChoiceChipButton(
              label: 'جديد فقط'.tr,
              selected: controller.newOnly.value,
              onTap: controller.toggleNewOnly,
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: AppColors.border,
            ),
            for (final option in ProductSort.values)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChipButton(
                  label: option.label,
                  selected: controller.sort.value == option,
                  onTap: () => controller.selectSort(option),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Text(
            'مافي منتجات هنا حاليًا'.tr,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'جرّبي تغيّري الفلتر أو تصفّحي قسم تاني.'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

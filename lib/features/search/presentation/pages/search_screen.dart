import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/directional_arrow.dart';
import 'package:get/get.dart';
import 'package:toubna/core/widgets/error_state_view.dart';
import 'package:toubna/core/widgets/skeletons.dart';
import 'package:toubna/core/widgets/shimmer.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/choice_chip_button.dart';
import 'package:toubna/core/widgets/product_card.dart';
import 'package:toubna/features/categories/presentation/controllers/category_products_controller.dart';
import 'package:toubna/features/search/presentation/controllers/product_search_controller.dart';

class SearchScreen extends GetView<ProductSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 12),
              child: _SearchBar(),
            ),
            Expanded(
              child: Obx(() {
                final results = controller.results;
                final hasQuery = controller.query.value.isNotEmpty;
                return CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    if (!hasQuery)
                      const SliverToBoxAdapter(child: _Suggestions()),
                    SliverToBoxAdapter(
                      child: _SortBar(
                        count: results.length,
                        loading: controller.isLoading.value,
                      ),
                    ),
                    if (controller.hasError)
                      SliverToBoxAdapter(
                        child: ErrorStateView(
                          error: controller.error.value!,
                          onRetry: controller.retry,
                          compact: true,
                        ),
                      )
                    else if (controller.isLoading.value)
                      const SliverPadding(
                        padding: EdgeInsets.fromLTRB(15, 12, 15, 24),
                        sliver: Shimmer(
                          child: SliverProductGridSkeleton(count: 4),
                        ),
                      )
                    else if (results.isEmpty)
                      SliverToBoxAdapter(
                        child: _NoResults(query: controller.query.value),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(15, 12, 15, 24),
                        sliver: SliverGrid.builder(
                          gridDelegate: productGridDelegate(context),
                          itemCount: results.length,
                          itemBuilder: (context, i) {
                            final p = results[i];
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
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر الرجوع + حقل البحث (بنفس شكل شريط البحث في الرئيسية).
class _SearchBar extends GetView<ProductSearchController> {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: 'رجوع'.tr,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Get.back(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: const DirectionalArrow(back: true),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: controller.textController,
              focusNode: controller.focusNode,
              autofocus: controller.autofocus,
              textInputAction: TextInputAction.search,
              onChanged: controller.onChanged,
              onSubmitted: controller.searchFor,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                hintText: 'ابحثي عن توب، لون، أو خامة…'.tr,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/icons/search.png',
                    color: AppColors.textDark,
                  ),
                ),
                suffixIcon: Obx(
                  () => controller.query.value.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: 'مسح'.tr,
                          onPressed: controller.clear,
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Suggestions extends GetView<ProductSearchController> {
  const _Suggestions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 4, 15, 16),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.recent.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(child: _Title('عمليات البحث الأخيرة'.tr)),
                  TextButton(
                    onPressed: controller.clearRecent,
                    child: Text('مسح'.tr),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final text in controller.recent)
                    ChoiceChipButton(
                      label: text.tr,
                      icon: Icons.history,
                      selected: false,
                      onTap: () => controller.searchFor(text.tr),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            _Title('اقتراحات'.tr),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final text in ProductSearchController.suggestions)
                  ChoiceChipButton(
                    label: text.tr,
                    selected: false,
                    onTap: () => controller.searchFor(text.tr),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SortBar extends GetView<ProductSearchController> {
  final int count;
  final bool loading;

  const _SortBar({required this.count, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 8),
          child: _Title(
            loading
                ? 'جاري البحث…'.tr
                : controller.query.value.isEmpty
                ? 'كل المنتجات (@p0)'.trParams({'p0': '$count'})
                : 'النتائج (@p0)'.trParams({'p0': '$count'}),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
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
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;

  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icons/search.png',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'مافي نتائج لـ "@p0"'.trParams({'p0': query}),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'جرّبي كلمة تانية، مثلاً اسم الخامة أو اللون.'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;

  const _Title(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
    ),
  );
}

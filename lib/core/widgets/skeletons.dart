import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/product_card.dart';
import 'package:toubna/core/widgets/shimmer.dart';

/// هيكل كارت المنتج — بنفس مقاسات [ProductCard].
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
            child: Bone(height: 150, width: double.infinity, radius: 0),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.line(width: 96, height: 14),
                SizedBox(height: 10),
                Bone.line(width: 70),
                SizedBox(height: 12),
                Bone.line(width: 84, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// شبكة هياكل منتجات (داخل Column).
class ProductGridSkeleton extends StatelessWidget {
  final int count;

  const ProductGridSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: count,
      gridDelegate: productGridDelegate(context),
      itemBuilder: (_, _) => const ProductCardSkeleton(),
    );
  }
}

/// شبكة هياكل منتجات (داخل CustomScrollView).
class SliverProductGridSkeleton extends StatelessWidget {
  final int count;

  const SliverProductGridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: productGridDelegate(context),
      itemCount: count,
      itemBuilder: (_, _) => const ProductCardSkeleton(),
    );
  }
}

/// هيكل صف أفقي: صورة + أسطر (وصل حديثًا، السلة، ...).
class RowCardSkeleton extends StatelessWidget {
  final double imageSize;

  const RowCardSkeleton({super.key, this.imageSize = 104});

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Bone(width: imageSize, height: imageSize, radius: 18),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone(width: 70, height: 22, radius: 100),
                SizedBox(height: 12),
                Bone.line(width: 120, height: 16),
                SizedBox(height: 10),
                Bone.line(width: 90),
                SizedBox(height: 12),
                Bone.line(width: 80, height: 14),
              ],
            ),
          ),
          const Bone(width: 44, height: 44, radius: 14),
        ],
      ),
    );
  }
}

/// هيكل كارت الطلب — بنفس ترتيب OrderCard.
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonCard(
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Bone(width: 44, height: 44, radius: 14),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.line(width: 130, height: 16),
                    SizedBox(height: 8),
                    Bone.line(width: 80),
                  ],
                ),
              ),
              Bone(width: 76, height: 28, radius: 12),
            ],
          ),
          SizedBox(height: 16),
          Bone(height: 6, width: double.infinity, radius: 3),
          SizedBox(height: 20),
          Row(
            children: [
              Bone(width: 44, height: 50, radius: 12),
              SizedBox(width: 6),
              Bone(width: 44, height: 50, radius: 12),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.line(width: 70, height: 14),
                    SizedBox(height: 8),
                    Bone.line(width: 110),
                  ],
                ),
              ),
              Bone.line(width: 80, height: 18),
            ],
          ),
          SizedBox(height: 16),
          Bone(height: 50, width: double.infinity, radius: 14),
        ],
      ),
    );
  }
}

/// عنوان قسم (خط عريض) مع "عرض الكل".
class SectionHeaderSkeleton extends StatelessWidget {
  final bool seeAll;

  const SectionHeaderSkeleton({super.key, this.seeAll = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Bone.line(width: 130, height: 24),
        const Spacer(),
        if (seeAll) const Bone.line(width: 64, height: 16),
      ],
    );
  }
}

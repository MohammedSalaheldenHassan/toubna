import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/shimmer.dart';
import 'package:toubna/core/widgets/skeletons.dart';

/// هيكل أقسام الرئيسية أثناء التحميل — بنفس ترتيب ومقاسات المحتوى.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // البانر + النقاط
          const Bone(height: 180, radius: 20),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Bone(width: 20, height: 6, radius: 3),
              SizedBox(width: 6),
              Bone(width: 6, height: 6, radius: 3),
              SizedBox(width: 6),
              Bone(width: 6, height: 6, radius: 3),
            ],
          ),
          const SizedBox(height: 16),
          // شريط المزايا
          const Bone(height: 78, radius: 18),
          const SizedBox(height: 20),

          // الأقسام
          const SectionHeaderSkeleton(),
          const SizedBox(height: 15),
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 70),
                          child: const AspectRatio(
                            aspectRatio: 1,
                            child: Bone(radius: 100),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Bone.line(width: 44),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // الأكثر مبيعًا
          const SectionHeaderSkeleton(),
          const SizedBox(height: 12),
          const ProductGridSkeleton(count: 4),
          const SizedBox(height: 24),

          // حسب المناسبة
          const SectionHeaderSkeleton(),
          const SizedBox(height: 12),
          SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => const SizedBox(
                width: 148,
                child: SkeletonCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(17),
                        ),
                        child: Bone(
                          height: 108,
                          width: double.infinity,
                          radius: 0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Bone.line(width: 60, height: 16),
                            SizedBox(height: 8),
                            Bone.line(width: 100, height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // وصل حديثًا
          const SectionHeaderSkeleton(),
          const SizedBox(height: 10),
          const RowCardSkeleton(),
          const SizedBox(height: 10),
          const RowCardSkeleton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

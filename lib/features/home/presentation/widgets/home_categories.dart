import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:get/get.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/features/home/presentation/controllers/home_controller.dart';
import 'package:toubna/features/home/presentation/widgets/section_header.dart';

class HomeCategories extends GetView<HomeController> {
  const HomeCategories({super.key});

  /// الأقسام اللي تظهر كدوائر (بأغلفتها من الكتالوج).
  static const _ids = ['swiss', 'foal', 'garmasis', 'chiffon', 'mashghool'];
  static const _labels = {'swiss': 'سويسري'};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: 'الأقسام'.tr, onSeeAll: controller.openCategories),
        const SizedBox(height: 15),
        // كل عنصر ياخد خُمس العرض، والدائرة 70 كحد أقصى
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final category in _ids.map(Catalog.byId))
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.openCategory(category.id),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 70),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipOval(child: AppImage(category.image)),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _labels[category.id]?.tr ?? category.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

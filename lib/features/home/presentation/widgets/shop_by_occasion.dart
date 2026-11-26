import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:get/get.dart';
import 'package:toubna/features/home/presentation/controllers/home_controller.dart';
import 'package:toubna/features/home/presentation/widgets/section_header.dart';

class ShopByOccasion extends GetView<HomeController> {
  const ShopByOccasion({super.key});

  @override
  Widget build(BuildContext context) {
    final occasions = controller.occasions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'تسوقي حسب المناسبة'.tr,
          subtitle: 'لكل مناسبة توبها'.tr,
          onSeeAll: controller.openCategories,
        ),
        const SizedBox(height: 12),
        SizedBox(
          // 176 بالخط العادي، ويزيد لو المستخدم كبّر الخط من إعدادات الجهاز
          height: 128 + MediaQuery.textScalerOf(context).scale(48),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: occasions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final o = occasions[i];
              return SizedBox(
                width: 148,
                child: Material(
                  color: Colors.white,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFEADFE3)),
                  ),
                  child: InkWell(
                    onTap: () => controller.openCategory(o.categoryId),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppImage(o.image, height: 108, width: double.infinity),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                o.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF221A22),
                                ),
                              ),
                              Text(
                                o.sub,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B5E66),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

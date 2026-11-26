import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:get/get.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/routes/app_routes.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  static const _category = Catalog.swiss;
  // getter (مش static final) عشان النصوص تتترجم مع تغيير اللغة
  Map<String, dynamic> get featuredCategory => {
    'name': _category.name,
    'count': _category.countText,
    'badge': 'الأكثر طلبًا'.tr,
    'image': _category.image,
  };
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.category, arguments: _category.id),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Color(0xffEADFE3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Color(0xffFBEFD0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          featuredCategory['badge'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: Color(0xff7A4A00),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      featuredCategory['name'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      featuredCategory['count'],
                      style: TextStyle(fontSize: 18, color: Color(0xff6B5E66)),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: ClipRRect(
                // الصورة في نهاية الكارت: شمال في العربي، يمين في الإنجليزي
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(18),
                  bottomEnd: Radius.circular(18),
                ),
                child: AppImage(featuredCategory['image'], fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

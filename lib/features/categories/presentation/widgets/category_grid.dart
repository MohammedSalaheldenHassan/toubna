import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/directional_arrow.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:get/get.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/routes/app_routes.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  static const categories = Catalog.gridCategories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // عمودين على الهاتف، 3 على التابلت الصغير، 4 على الكبير
        crossAxisCount: switch (MediaQuery.sizeOf(context).width) {
          >= 900 => 4,
          >= 600 => 3,
          _ => 2,
        },
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // 175 بالخط العادي، ويزيد مع تكبير الخط
        mainAxisExtent: 129 + MediaQuery.textScalerOf(context).scale(46),
      ),
      itemCount: categories.length,

      itemBuilder: (context, index) {
        final category = categories[index];
        return Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            side: BorderSide(color: Color(0xffEADFE3)),
          ),
          child: InkWell(
            onTap: () =>
                Get.toNamed(AppRoutes.category, arguments: category.id),
            child: Column(
              children: [
                SizedBox(
                  height: 104,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    child: AppImage(category.image),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              category.countText,
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                      const DirectionalArrow(back: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

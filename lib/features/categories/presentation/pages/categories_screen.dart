import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/features/categories/presentation/widgets/banner.dart';
import 'package:toubna/features/categories/presentation/widgets/category_grid.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "الأقسام".tr,
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                  Tooltip(
                    message: 'بحث'.tr,
                    child: Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xffEADFE3)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Get.toNamed(
                          AppRoutes.search,
                          arguments: {'focus': true},
                        ),
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset("assets/icons/search.png"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const BannerScreen(),
              const SizedBox(height: 20),
              const CategoryGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

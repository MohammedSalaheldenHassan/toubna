import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/widgets/error_state_view.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/shimmer.dart';
import 'package:toubna/features/home/presentation/controllers/home_controller.dart';
import 'package:toubna/features/home/presentation/widgets/adds.dart';
import 'package:toubna/features/home/presentation/widgets/app_bar.dart';
import 'package:toubna/features/home/presentation/widgets/home_categories.dart';
import 'package:toubna/features/home/presentation/widgets/featured.dart';
import 'package:toubna/features/home/presentation/widgets/home_skeleton.dart';
import 'package:toubna/features/home/presentation/widgets/new_arrival.dart';
import 'package:toubna/features/home/presentation/widgets/search.dart';
import 'package:toubna/features/home/presentation/widgets/shop_by_occasion.dart';
import 'package:toubna/features/home/presentation/widgets/trust_strip.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshHome,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const HomeAppBar(),
                const SizedBox(height: 20),
                const Search(),
                const SizedBox(height: 20),
                // هيكل لامع لحد ما البيانات تجهز، وبعدها المحتوى بـ fade
                Obx(
                  () => controller.hasError
                      ? ErrorStateView(
                          error: controller.error.value!,
                          onRetry: controller.retry,
                        )
                      : LoadingSwitcher(
                          loading: controller.isLoading.value,
                          skeleton: const HomeSkeleton(),
                          child: const Column(
                            children: [
                              Adds(),
                              SizedBox(height: 16),
                              TrustStrip(),
                              SizedBox(height: 20),
                              HomeCategories(),
                              SizedBox(height: 20),
                              Featured(),
                              SizedBox(height: 20),
                              ShopByOccasion(),
                              SizedBox(height: 20),
                              NewArrival(),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/widgets/error_state_view.dart';
import 'package:toubna/core/widgets/skeletons.dart';
import 'package:toubna/core/widgets/shimmer.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/features/my_order/presentation/controllers/my_order_controller.dart';
import 'package:toubna/features/my_order/presentation/widgets/order_card.dart';

class MyOrderScreen extends GetView<MyOrderController> {
  const MyOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "طلباتي".tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Obx(
                () => Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFFF3E4EB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // الحالية
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectTab(0),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 0
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'الحالية'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: controller.selectedTab.value == 0
                                    ? Color(0xFF7A1F4B)
                                    : Color(0xFF6B5E66),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),

                      // السابقة
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectTab(1),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 1
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'السابقة'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: controller.selectedTab.value == 1
                                    ? Color(0xFF7A1F4B)
                                    : Color(0xFF6B5E66),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.hasError) {
                    return Center(
                      child: SingleChildScrollView(
                        child: ErrorStateView(
                          error: controller.error.value!,
                          onRetry: controller.retry,
                        ),
                      ),
                    );
                  }
                  if (controller.isLoading.value) {
                    return Shimmer(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 20),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, _) => const OrderCardSkeleton(),
                      ),
                    );
                  }
                  final list = controller.visibleOrders;
                  if (list.isEmpty) {
                    return _EmptyOrders(
                      current: controller.selectedTab.value == 0,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        OrderCard(order: list[index]),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final bool current;

  const _EmptyOrders({required this.current});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(26),
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icons/orders.png',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              current ? 'مافي طلبات حالية'.tr : 'مافي طلبات سابقة'.tr,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'لما تطلبي توب، هتلقيه هنا وتقدري تتابعيه خطوة بخطوة.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

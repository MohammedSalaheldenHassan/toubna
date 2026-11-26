import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/user_avatar.dart';
import 'package:toubna/features/account/presentation/controllers/account_controller.dart';
import 'package:toubna/features/my_order/data/order_models.dart';
import 'package:toubna/features/my_order/presentation/widgets/order_status_style.dart';

class AccountInfo extends GetView<AccountController> {
  const AccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "حسابي".tr,
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const _ProfileCard(),
        const SizedBox(height: 20),
        Row(
          children: [
            _stat(
              () => "${controller.ordersCount}",
              "طلبات".tr,
              controller.openOrders,
            ),
            const SizedBox(width: 12),
            _stat(
              () => "${controller.favoritesCount}",
              "في المفضله".tr,
              controller.openFavorites,
            ),
            const SizedBox(width: 12),
            _stat(
              () => "${controller.addressesCount}",
              "عناوين".tr,
              controller.openLocations,
            ),
          ],
        ),
        // متابعة سريعة لآخر طلب لسه في الطريق
        Obx(() {
          final order = controller.activeOrder;
          if (order == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: _ActiveOrderCard(order: order),
          );
        }),
      ],
    );
  }

  Widget _stat(String Function() count, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xffEADFE3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 70,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    // Obx: العدد يتحدّث مباشرة (مثلاً لما تضيفي للمفضلة)
                    Obx(
                      () => Text(
                        count(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff7A1F4B),
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Text(label, style: const TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بطاقة الملف الشخصي العنابية (تتحدّث مع تعديل الاسم).
class _ProfileCard extends GetView<AccountController> {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xff7A1F4B),
        image: const DecorationImage(
          image: AssetImage("assets/images/patterns/plum_weave_tile_soft.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldLight, width: 2),
            ),
            child: const UserAvatar(
              size: 64,
              background: Colors.white,
              foreground: Color(0xff7A1F4B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    user.phone.value,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'عضوة منذ @p0'.trParams({'p0': user.memberSince.tr}),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'تعديل الملف الشخصي'.tr,
            child: Material(
              color: const Color.fromARGB(80, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: controller.openEditProfile,
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Image.asset(
                      "assets/icons/edit.png",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveOrderCard extends GetView<AccountController> {
  final Order order;

  const _ActiveOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => controller.openTracking(order),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: status.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(status.icon, color: status.foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب @p0 · @p1'.trParams({
                        'p0': order.number,
                        'p1': status.label,
                      }),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OrderProgressBar(status: status),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'تتبعي'.tr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

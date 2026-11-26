import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/i18n/plural.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/features/addresses/presentation/controllers/addresses_controller.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';
import 'package:toubna/features/my_order/presentation/widgets/order_card.dart';

/// تأكيد الطلب: عنوان التوصيل + طريقة الدفع + الإجمالي.
class CheckoutSheet extends GetView<CartController> {
  const CheckoutSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const CheckoutSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = Get.find<AddressesController>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Obx(() {
          final address = addresses.defaultAddress;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9C9D0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'تأكيد الطلب'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              _Tile(
                icon: 'assets/icons/location.png',
                title: address == null
                    ? 'مافي عنوان توصيل'.tr
                    : 'التوصيل إلى: @p0'.trParams({'p0': address.label.title}),
                subtitle: address == null
                    ? 'ضيفي عنوان عشان نقدر نوصّل طلبك'.tr
                    : address.fullText,
                warning: address == null,
                action: address == null ? 'إضافة'.tr : 'تغيير'.tr,
                onAction: () => Get.toNamed(
                  address == null ? AppRoutes.addressForm : AppRoutes.locations,
                ),
              ),
              const SizedBox(height: 10),
              _Tile(
                icon: 'assets/icons/cash.png',
                title: 'الدفع عند الاستلام'.tr,
                subtitle: 'ادفعي نقدًا أو بنكك للمندوب'.tr,
                selected: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'الإجمالي (@items)'.trParams({
                        'items': itemsText(controller.count),
                      }),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Text(
                    formatPrice(controller.total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: address == null ? 0.5 : 1,
                child: IgnorePointer(
                  ignoring: address == null,
                  child: OrderButton.primary(
                    label: 'تأكيد الطلب'.tr,
                    onTap: controller.confirmCheckout,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool warning;
  final bool selected;
  final String? action;
  final VoidCallback? onAction;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.warning = false,
    this.selected = false,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = warning ? AppColors.danger : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: warning
              ? AppColors.danger.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: warning ? const Color(0xFFFDECEC) : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: warning ? AppColors.danger : AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action!))
          else if (selected)
            const Icon(Icons.check_circle, color: AppColors.primary),
        ],
      ),
    );
  }
}

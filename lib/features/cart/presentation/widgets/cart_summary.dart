import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';
import 'package:toubna/features/cart/presentation/widgets/checkout_sheet.dart';
import 'package:toubna/features/my_order/presentation/widgets/order_card.dart';

/// شريط التقدّم نحو التوصيل المجاني.
class FreeDeliveryCard extends GetView<CartController> {
  const FreeDeliveryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reached = controller.hasFreeDelivery;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: reached ? const Color(0xFFE7F6EC) : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ImageIcon(
                  AssetImage(
                    reached
                        ? 'assets/icons/check.png'
                        : 'assets/icons/truck.png',
                  ),
                  size: 22,
                  color: reached ? const Color(0xFF166534) : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: reached
                      ? Text(
                          'طلبك مؤهل للتوصيل المجاني'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF166534),
                          ),
                        )
                      : Text.rich(
                          TextSpan(
                            text: 'باقي '.tr,
                            children: [
                              TextSpan(
                                text: formatPrice(
                                  controller.remainingForFreeDelivery,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              TextSpan(text: ' وتحصلي على توصيل مجاني'.tr),
                            ],
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              tween: Tween(end: controller.freeDeliveryProgress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  color: reached ? const Color(0xFF16A34A) : AppColors.primary,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// حقل كود الخصم، أو الكود المطبّق مع زر إزالة.
class CouponCard extends GetView<CartController> {
  const CouponCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Obx(() {
        final code = controller.couponCode.value;
        if (code != null) {
          return Row(
            children: [
              const ImageIcon(
                AssetImage('assets/icons/coupon.png'),
                color: Color(0xFF166534),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'الكود @p0 — خصم @p1٪'.trParams({
                    'p0': code,
                    'p1': '${controller.discountPercent}',
                  }),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.removeCoupon,
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: Text('إزالة'.tr),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: TextField(
                      controller: controller.couponController,
                      textCapitalization: TextCapitalization.characters,
                      textDirection: TextDirection.ltr,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => controller.applyCoupon(),
                      decoration: InputDecoration(
                        hintText: 'كود الخصم'.tr,
                        hintTextDirection: Directionality.of(context),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: ImageIcon(
                            AssetImage('assets/icons/coupon.png'),
                            color: AppColors.textMuted,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: controller.applyCoupon,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'تطبيق'.tr,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            if (controller.couponError.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  controller.couponError.value!,
                  style: const TextStyle(fontSize: 13, color: AppColors.danger),
                ),
              ),
          ],
        );
      }),
    );
  }
}

/// ملخص الحساب (المجموع، التوصيل، الخصم، الإجمالي).
class CartSummaryCard extends GetView<CartController> {
  const CartSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Obx(
        () => Column(
          children: [
            _line(
              'المجموع (@p0)'.trParams({'p0': '${controller.count}'}),
              formatPrice(controller.subtotal),
            ),
            _line(
              'التوصيل'.tr,
              controller.delivery == 0
                  ? 'مجاني'.tr
                  : formatPrice(controller.delivery),
              valueColor: controller.delivery == 0
                  ? const Color(0xFF166534)
                  : null,
            ),
            if (controller.discount > 0)
              _line(
                'الخصم (@p0٪)'.trParams({
                  'p0': '${controller.discountPercent}',
                }),
                '- ${formatPrice(controller.discount)}',
                valueColor: const Color(0xFF166534),
              ),
            const Divider(height: 20),
            _line('الإجمالي'.tr, formatPrice(controller.total), bold: true),
          ],
        ),
      ),
    );
  }

  Widget _line(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color:
                valueColor ?? (bold ? AppColors.primary : AppColors.textDark),
          ),
        ),
      ],
    ),
  );
}

/// الشريط الثابت أسفل السلة: الإجمالي + إتمام الطلب.
class CheckoutBar extends GetView<CartController> {
  const CheckoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإجمالي'.tr,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  formatPrice(controller.total),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OrderButton.primary(
              label: 'إتمام الطلب'.tr,
              icon: 'assets/icons/bag.png',
              onTap: CheckoutSheet.show,
            ),
          ),
        ],
      ),
    );
  }
}

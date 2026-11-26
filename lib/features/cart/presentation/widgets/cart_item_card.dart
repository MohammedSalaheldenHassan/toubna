import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:get/get.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/features/cart/data/cart_item.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';

/// سطر منتج في السلة — يتسحب للحذف، مع تعديل الكمية.
class CartItemCard extends GetView<CartController> {
  final CartItem item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('cart-${item.id}'),
      // السحب لليسار في اللغتين: في العربي (RTL) ده startToEnd،
      // وفي الإنجليزي (LTR) endToStart. الخلفية بتظهر على اليمين.
      direction: Directionality.of(context) == TextDirection.rtl
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart,
      onDismissed: (_) => controller.remove(item),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: AppColors.danger),
            Text(
              'حذف'.tr,
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AppImage(item.image, width: 84, height: 100),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          tooltip: 'حذف من السلة'.tr,
                          padding: EdgeInsets.zero,
                          onPressed: () => controller.remove(item),
                          icon: const ImageIcon(
                            AssetImage('assets/icons/trash.png'),
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.kind,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (item.variant != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.variant!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            formatPrice(item.lineTotal),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _QtyStepper(item: item),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// نفس شكل عداد الكمية في صفحة المنتج (أصغر).
class _QtyStepper extends GetView<CartController> {
  final CartItem item;

  const _QtyStepper({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        // ثابت: + يمين و− شمال في اللغتين (العُرف في الاتنين)
        textDirection: TextDirection.rtl,
        children: [
          _button(
            '+',
            'زيادة الكمية'.tr,
            item.qty < item.maxQty ? () => controller.increment(item) : null,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '${item.qty}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          _button(
            '−',
            'إنقاص الكمية'.tr,
            item.qty > 1 ? () => controller.decrement(item) : null,
          ),
        ],
      ),
    );
  }

  Widget _button(String label, String tooltip, VoidCallback? onTap) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onTap == null
                      ? const Color(0xFFB98AA0)
                      : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

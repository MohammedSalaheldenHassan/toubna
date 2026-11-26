import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:get/get.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/features/my_order/data/order_models.dart';
import 'package:toubna/features/my_order/presentation/controllers/my_order_controller.dart';
import 'package:toubna/features/my_order/presentation/widgets/order_status_style.dart';

class OrderCard extends GetView<MyOrderController> {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => controller.openTracking(order),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الرأس: أيقونة الحالة + رقم الطلب والتاريخ + الحالة
              Row(
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
                          'طلب @p0'.trParams({'p0': order.number}),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const ImageIcon(
                              AssetImage('assets/icons/clock.png'),
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                order.date,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OrderStatusPill(status: status),
                ],
              ),

              // تقدّم الطلب (للطلبات الحالية بس)
              if (status.isActive) ...[
                const SizedBox(height: 14),
                OrderProgressBar(status: status),
                const SizedBox(height: 8),
                Text(
                  status.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                if (order.eta != null)
                  Text.rich(
                    TextSpan(
                      text: 'التوصيل المتوقع: '.tr,
                      children: [
                        TextSpan(
                          text: order.eta,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textBody,
                    ),
                  ),
              ],

              const Divider(height: 26),

              // المنتجات والإجمالي
              Row(
                children: [
                  OrderThumbnails(images: order.images),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.countText(order.itemCount),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBody,
                          ),
                        ),
                        Text(
                          order.items.map((i) => i.name).join('، '.tr),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'الإجمالي'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        order.totalText,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // الأزرار
              if (status.isActive)
                OrderButton.primary(
                  label: 'تتبع الطلب'.tr,
                  icon: 'assets/icons/truck.png',
                  onTap: () => controller.openTracking(order),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OrderButton.outlined(
                        label: 'التفاصيل'.tr,
                        onTap: () => controller.openTracking(order),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OrderButton.primary(
                        label: 'إعادة الطلب'.tr,
                        icon: 'assets/icons/bag.png',
                        onTap: () => controller.reorder(order),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// صور المنتجات متراكبة (3 كحد أقصى + عدّاد للباقي).
class OrderThumbnails extends StatelessWidget {
  final List<String> images;

  const OrderThumbnails({super.key, required this.images});

  static const _maxShown = 3;

  @override
  Widget build(BuildContext context) {
    final shown = images.take(_maxShown).toList();
    final extra = images.length - shown.length;
    final count = shown.length + (extra > 0 ? 1 : 0);
    return SizedBox(
      width: 44 + (count - 1) * 28.0,
      height: 50,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            PositionedDirectional(
              start: i * 28.0,
              child: _thumb(
                DecorationImage(
                  image: AppImage.provider(shown[i]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (extra > 0)
            PositionedDirectional(
              start: shown.length * 28.0,
              child: _thumb(
                null,
                child: Text(
                  '+$extra',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _thumb(DecorationImage? image, {Widget? child}) => Container(
    width: 44,
    height: 50,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.primarySoft,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white, width: 2),
      image: image,
    ),
    child: child,
  );
}

/// زر الطلبات: ممتلئ (عنابي) أو بإطار.
class OrderButton extends StatelessWidget {
  final String label;
  final String? icon;
  final VoidCallback onTap;
  final bool filled;
  final Color color;

  const OrderButton.primary({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  }) : filled = true,
       color = AppColors.primary;

  const OrderButton.outlined({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color = AppColors.primary,
  }) : filled = false;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : color;
    return Material(
      color: filled ? color : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: filled ? BorderSide.none : BorderSide(color: color),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                ImageIcon(AssetImage(icon!), size: 20, color: foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: foreground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/features/my_order/data/order_models.dart';

/// ألوان وأيقونة كل حالة — مرجع واحد للكارت وصفحة التتبع.
extension OrderStatusStyle on OrderStatus {
  Color get background => switch (this) {
    OrderStatus.placed || OrderStatus.preparing => const Color(0xffFBEFD0),
    OrderStatus.outForDelivery => AppColors.primarySoft,
    OrderStatus.delivered => const Color(0xFFE7F6EC),
    OrderStatus.cancelled => const Color(0xFFFDECEC),
  };

  Color get foreground => switch (this) {
    OrderStatus.placed || OrderStatus.preparing => const Color(0xff7A4A00),
    OrderStatus.outForDelivery => AppColors.primary,
    OrderStatus.delivered => const Color(0xFF166534),
    OrderStatus.cancelled => AppColors.danger,
  };

  String get icon => switch (this) {
    OrderStatus.placed => 'assets/icons/document.png',
    OrderStatus.preparing => 'assets/icons/package.png',
    OrderStatus.outForDelivery => 'assets/icons/truck.png',
    OrderStatus.delivered => 'assets/icons/check.png',
    OrderStatus.cancelled => 'assets/icons/close.png',
  };
}

class OrderStatusPill extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: status.background,
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: status.foreground,
        ),
      ),
    );
  }
}

/// شريط التقدّم المقسّم لأربع مراحل.
class OrderProgressBar extends StatelessWidget {
  final OrderStatus status;
  final Color activeColor;
  final Color inactiveColor;

  const OrderProgressBar({
    super.key,
    required this.status,
    this.activeColor = AppColors.primary,
    this.inactiveColor = AppColors.border,
  });

  @override
  Widget build(BuildContext context) {
    final reached = status.stepIndex;
    return Row(
      children: [
        for (var i = 0; i < OrderStatus.steps.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: i <= reached ? 1 : 0),
              duration: Duration(milliseconds: 400 + i * 150),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  color: activeColor,
                  backgroundColor: inactiveColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

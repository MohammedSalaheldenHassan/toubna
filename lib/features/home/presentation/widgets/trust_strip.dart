import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/theme/app_colors.dart';

/// ليه تتسوقي من توبنا: ثلاث مزايا مختصرة.
class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  static const _items = [
    ('assets/icons/truck.png', 'توصيل سريع', 'لكل الولايات'),
    ('assets/icons/cash.png', 'الدفع عند الاستلام', 'بدون رسوم'),
    ('assets/icons/check.png', 'إرجاع سهل', 'خلال 7 أيام'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (final (i, (icon, title, sub)) in _items.indexed) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 36,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            Expanded(
              child: Column(
                children: [
                  ImageIcon(
                    AssetImage(icon),
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      sub.tr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

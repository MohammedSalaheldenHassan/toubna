import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/features/auth/register/presentation/controllers/register_controller.dart';

class Term extends GetView<RegisterController> {
  const Term({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.toggleTerms,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // المربع
            Obx(() {
              final agree = controller.agreeTerms.value;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: agree ? const Color(0xFF7A1F4B) : Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: agree
                        ? const Color(0xFF7A1F4B)
                        : const Color(0xFFC9B8C0),
                    width: 2,
                  ),
                ),
                child: agree
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              );
            }),
            const SizedBox(width: 10),

            // النص
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: Color(0xFF4A3F46),
                  ),
                  children: [
                    TextSpan(text: 'أوافق على '.tr),
                    _link('الشروط والأحكام'.tr),
                    TextSpan(text: ' و'.tr),
                    _link('سياسة الخصوصية'.tr),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// كلمة الرابط (بخط عريض وتحتها خط) — تفتح صفحة الشروط بدل ما تعلّم الخانة.
  InlineSpan _link(String text) => WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: GestureDetector(
      onTap: controller.openTerms,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.7,
          color: Color(0xFF7A1F4B),
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF7A1F4B),
        ),
      ),
    ),
  );
}

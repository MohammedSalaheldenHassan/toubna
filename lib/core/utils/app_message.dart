import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/theme/app_colors.dart';

/// رسالة قصيرة أسفل الشاشة بشكل موحّد في كل التطبيق،
/// مع زر اختياري (مثلاً "تراجع").
void showAppMessage(
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  Get
    ..closeAllSnackbars()
    ..showSnackbar(
      GetSnackBar(
        message: message,
        duration: Duration(seconds: actionLabel == null ? 2 : 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        backgroundColor: const Color(0xFF221A22),
        mainButton: actionLabel == null
            ? null
            : TextButton(
                onPressed: () {
                  Get.closeAllSnackbars();
                  onAction?.call();
                },
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
}

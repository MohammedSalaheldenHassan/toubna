import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/theme/app_theme.dart';
import 'package:toubna/core/widgets/otp_input.dart';
import 'package:toubna/core/widgets/page_header.dart';
import 'package:toubna/core/widgets/primary_button.dart';
import 'package:toubna/features/auth/verify_phone/verify_phone_controller.dart';

class VerifyPhoneScreen extends GetView<VerifyPhoneController> {
  const VerifyPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(title: 'تأكيد رقم الموبايل'.tr),
              const SizedBox(height: 28),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'أدخلي رمز التحقق'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.displayFontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'أرسلنا رمز من 4 أرقام في رسالة إلى'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                controller.phone,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: controller.changeNumber,
                  child: Text('غيّري الرقم'.tr),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => OtpInput(
                  controller: controller.codeController,
                  focusNode: controller.focusNode,
                  length: VerifyPhoneController.codeLength,
                  hasError: controller.errorText.value != null,
                  enabled: !controller.locked,
                  onChanged: controller.onChanged,
                  onCompleted: (_) => controller.verify(),
                ),
              ),
              Obx(
                () => AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: controller.errorText.value == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            controller.errorText.value!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => PrimaryButton(
                  label: 'تأكيد وإنشاء الحساب'.tr,
                  loading: controller.isVerifying.value,
                  onTap: controller.locked ? null : controller.verify,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final waiting = controller.secondsLeft.value > 0;
                if (controller.isSending.value) {
                  return Center(
                    child: Text(
                      'جاري إرسال الرمز…'.tr,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }
                return Center(
                  child: waiting
                      ? Text(
                          'إعادة الإرسال بعد @p0'.trParams({
                            'p0': controller.timerText,
                          }),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        )
                      : TextButton(
                          onPressed: controller.resend,
                          child: Text(
                            'ما وصلك؟ إعادة الإرسال'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

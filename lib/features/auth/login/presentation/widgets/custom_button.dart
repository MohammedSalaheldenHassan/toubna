import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/widgets/primary_button.dart';
import 'package:toubna/features/auth/login/presentation/controllers/login_controller.dart';

class CustomButton extends GetView<LoginController> {
  const CustomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Obx(
        () => PrimaryButton(
          label: "تسجيل الدخول".tr,
          loading: controller.isSubmitting.value,
          onTap: controller.login,
        ),
      ),
    );
  }
}

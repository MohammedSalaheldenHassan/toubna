import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/widgets/primary_button.dart';
import 'package:toubna/features/auth/register/presentation/controllers/register_controller.dart';

class RegisterButton extends GetView<RegisterController> {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Obx(
        () => PrimaryButton(
          label: " إنشاء الحساب".tr,
          loading: controller.isSubmitting.value,
          onTap: controller.register,
        ),
      ),
    );
  }
}

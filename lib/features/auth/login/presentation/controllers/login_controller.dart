import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/connectivity_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final hidePassword = true.obs;
  final isSubmitting = false.obs;

  void togglePassword() => hidePassword.toggle();

  Future<void> login() async {
    if (isSubmitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!requireOnline()) return;
    isSubmitting.value = true;
    // هنا لاحقًا: تنادي الـ API وتتحقق من البيانات وتحفظ التوكن
    await Future.delayed(const Duration(milliseconds: 700));
    if (isClosed) return;
    isSubmitting.value = false;
    Get.offAllNamed(AppRoutes.main);
  }

  void goToRegister() => Get.toNamed(AppRoutes.register);

  void openTerms() => Get.toNamed(AppRoutes.terms);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

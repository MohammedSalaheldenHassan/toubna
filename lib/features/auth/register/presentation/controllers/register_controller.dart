import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/connectivity_service.dart';
import 'package:toubna/core/utils/app_message.dart';
import 'package:toubna/core/utils/validators.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final agreeTerms = false.obs;
  final hidePassword = true.obs;
  final hideConfirm = true.obs;
  final isSubmitting = false.obs;

  void toggleTerms() => agreeTerms.toggle();
  void togglePassword() => hidePassword.toggle();
  void toggleConfirm() => hideConfirm.toggle();

  String? validateConfirm(String? value) =>
      Validators.confirm(value, passwordController.text);

  /// بعد التحقق من البيانات بنرسل رمز للموبايل — الحساب بيتعمل بعد تأكيد
  /// الرقم في صفحة التحقق.
  Future<void> register() async {
    if (isSubmitting.value) return;
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (!agreeTerms.value) {
      showAppMessage('يرجى الموافقة على الشروط والأحكام أولًا'.tr);
      return;
    }
    if (!requireOnline()) return;
    isSubmitting.value = true;
    // هنا لاحقًا: تنادي الـ API (يتأكد إن البريد والرقم مش مستخدمين)
    await Future.delayed(const Duration(milliseconds: 600));
    if (isClosed) return;
    isSubmitting.value = false;
    Get.toNamed(
      AppRoutes.verifyPhone,
      arguments: {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': Validators.formatSudanPhone(phoneController.text),
      },
    );
  }

  void goToLogin() => Get.offAllNamed(AppRoutes.login);

  void openTerms() => Get.toNamed(AppRoutes.terms);

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}

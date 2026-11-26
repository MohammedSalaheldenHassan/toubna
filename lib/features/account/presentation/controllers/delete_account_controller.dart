import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/app_storage.dart';
import 'package:toubna/core/services/connectivity_service.dart';
import 'package:toubna/core/services/favorites_controller.dart';
import 'package:toubna/core/services/user_controller.dart';
import 'package:toubna/core/utils/app_message.dart';
import 'package:toubna/features/addresses/presentation/controllers/addresses_controller.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';
import 'package:toubna/features/my_order/presentation/controllers/my_order_controller.dart';

/// حذف الحساب نهائيًا: تأكيد + كلمة المرور، وبعدها نمسح كل بيانات
/// المستخدمة من الجهاز ونرجع لصفحة الدخول.
class DeleteAccountController extends GetxController {
  final passwordController = TextEditingController();
  final understood = false.obs;
  final hidePassword = true.obs;
  final isDeleting = false.obs;
  final errorText = RxnString();
  final _password = ''.obs;

  @override
  void onInit() {
    super.onInit();
    passwordController.addListener(() {
      _password.value = passwordController.text;
      errorText.value = null;
    });
  }

  bool get canDelete =>
      understood.value && _password.value.isNotEmpty && !isDeleting.value;

  void toggleUnderstood() => understood.toggle();
  void togglePassword() => hidePassword.toggle();

  Future<void> deleteAccount() async {
    if (!canDelete) return;
    if (!requireOnline()) return;
    isDeleting.value = true;
    // هنا لاحقًا: await api.deleteAccount(password) — السيرفر يتأكد من
    // كلمة المرور ويحذف البيانات (ويرجع خطأ لو الكلمة غلط)
    await Future.delayed(const Duration(milliseconds: 900));
    if (isClosed) return;
    if (_password.value.length < 6) {
      isDeleting.value = false;
      errorText.value = 'كلمة المرور غير صحيحة'.tr;
      return;
    }
    await _clearLocalData();
    Get.offAllNamed(AppRoutes.login);
    showAppMessage('تم حذف حسابك. نتمنى نشوفك تاني في توبنا.'.tr);
  }

  /// كل بيانات الحساب على الجهاز (اللغة والـ onboarding بيفضلوا).
  static Future<void> _clearLocalData() async {
    await AppStorage.clearUserData();
    if (Get.isRegistered<CartController>()) Get.find<CartController>().clear();
    if (Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().clear();
    }
    if (Get.isRegistered<AddressesController>()) {
      Get.find<AddressesController>().clearAll();
    }
    if (Get.isRegistered<MyOrderController>()) {
      Get.find<MyOrderController>().clearAll();
    }
    if (Get.isRegistered<UserController>()) Get.find<UserController>().reset();
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}

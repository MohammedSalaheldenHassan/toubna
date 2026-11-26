import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:toubna/core/services/app_storage.dart';

/// بيانات المستخدمة الحالية — مشتركة بين حسابي وتعديل الملف الشخصي.
class UserController extends GetxController {
  // هنا لاحقًا: تجي من الـ API بعد تسجيل الدخول
  static const _demoName = "صلاح الدين حسن مهدي";
  static const _demoPhone = "+249 912 900 089";
  static const _demoEmail = "mohammedsalah@gmail.com";

  final name = _demoName.obs;
  final phone = _demoPhone.obs;
  final email = _demoEmail.obs;
  final phoneVerified = true.obs;

  /// مسار صورة الملف الشخصي على الجهاز (null = الحرف الأول من الاسم).
  final avatarPath = RxnString();
  final memberSince = "أكتوبر 2026";

  @override
  void onInit() {
    super.onInit();
    _restoreAvatar();
  }

  Future<void> _restoreAvatar() async {
    avatarPath.value = await AppStorage.readString(AppStorage.avatarKey);
  }

  String get initial {
    final n = name.value.trim();
    return n.isEmpty ? 'م' : n.characters.first;
  }

  void updateName(String value) => name.value = value.trim();

  Future<void> setAvatar(String? path) async {
    avatarPath.value = path;
    await AppStorage.writeString(AppStorage.avatarKey, path);
  }

  /// بعد إنشاء حساب جديد وتأكيد رقم الموبايل.
  void signUp({
    required String name,
    required String email,
    required String phone,
  }) {
    this.name.value = name;
    this.email.value = email;
    this.phone.value = phone;
    phoneVerified.value = true;
  }

  /// بعد حذف الحساب: نرجع لحالة "مافي مستخدمة".
  void reset() {
    name.value = _demoName;
    phone.value = _demoPhone;
    email.value = _demoEmail;
    avatarPath.value = null;
  }
}

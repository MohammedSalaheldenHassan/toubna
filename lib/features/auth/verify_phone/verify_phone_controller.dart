import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/connectivity_service.dart';
import 'package:toubna/core/services/user_controller.dart';
import 'package:toubna/core/utils/app_message.dart';

/// تأكيد رقم الموبايل بعد التسجيل: بنرسل رمز SMS والحساب بيتعمل بعد
/// ما المستخدمة تدخّله صح.
///
/// يفتح بـ Get.toNamed(AppRoutes.verifyPhone,
///   arguments: {'name': ..., 'email': ..., 'phone': ...})
class VerifyPhoneController extends GetxController {
  static const codeLength = 4;
  static const resendSeconds = 60;
  static const maxAttempts = 5;

  /// رمز التجربة لحد ما يتربط مزوّد الـ SMS (بيظهر في نسخة التطوير بس).
  static const demoCode = '1234';

  final codeController = TextEditingController();
  final focusNode = FocusNode();

  late final String name;
  late final String email;
  late final String phone;

  final secondsLeft = 0.obs;
  final isVerifying = false.obs;
  final isSending = false.obs;
  final errorText = RxnString();
  final attemptsLeft = maxAttempts.obs;

  String? _sentCode;
  Timer? _timer;

  bool get locked => attemptsLeft.value == 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments is Map ? Get.arguments as Map : const {};
    name = '${args['name'] ?? ''}';
    email = '${args['email'] ?? ''}';
    phone = '${args['phone'] ?? ''}';
    _sendCode();
  }

  Future<void> _sendCode() async {
    isSending.value = true;
    // هنا لاحقًا: await api.sendOtp(phone) — مزوّد SMS أو Firebase Auth
    await Future.delayed(const Duration(milliseconds: 400));
    if (isClosed) return;
    _sentCode = demoCode;
    isSending.value = false;
    _startTimer();
    if (kDebugMode) {
      showAppMessage('رمز التجربة: @p0'.trParams({'p0': demoCode}));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    secondsLeft.value = resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value <= 1) {
        secondsLeft.value = 0;
        t.cancel();
      } else {
        secondsLeft.value--;
      }
    });
  }

  /// "0:45"
  String get timerText {
    final s = secondsLeft.value;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  void onChanged(String _) => errorText.value = null;

  Future<void> resend() async {
    if (secondsLeft.value > 0 || isSending.value) return;
    if (!requireOnline()) return;
    codeController.clear();
    errorText.value = null;
    attemptsLeft.value = maxAttempts;
    await _sendCode();
    focusNode.requestFocus();
  }

  Future<void> verify() async {
    if (isVerifying.value || locked) return;
    final code = codeController.text;
    if (code.length < codeLength) {
      errorText.value = 'اكتبي الرمز كامل (@p0 أرقام)'.trParams({
        'p0': '$codeLength',
      });
      return;
    }
    if (!requireOnline()) return;
    isVerifying.value = true;
    // هنا لاحقًا: await api.verifyOtp(phone, code) ثم إنشاء الحساب
    await Future.delayed(const Duration(milliseconds: 700));
    if (isClosed) return;
    isVerifying.value = false;

    if (code != _sentCode) {
      attemptsLeft.value--;
      codeController.clear();
      errorText.value = locked
          ? 'محاولات كتيرة غلط. اطلبي رمز جديد.'.tr
          : 'الرمز غير صحيح — باقي @p0 محاولات'.trParams({
              'p0': '${attemptsLeft.value}',
            });
      return;
    }

    Get.find<UserController>().signUp(name: name, email: email, phone: phone);
    Get.offAllNamed(AppRoutes.main);
    showAppMessage('تم تأكيد رقمك وإنشاء حسابك، أهلاً بيك في توبنا!'.tr);
  }

  /// "غيّري الرقم": رجوع لصفحة التسجيل.
  void changeNumber() => Get.back();

  @override
  void onClose() {
    _timer?.cancel();
    codeController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}

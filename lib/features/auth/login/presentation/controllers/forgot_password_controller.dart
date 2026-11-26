import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/services/connectivity_service.dart';
import 'package:toubna/core/utils/validators.dart';

class ForgotPasswordController extends GetxController {
  static const codeLength = 4;
  static const resendSeconds = 45;

  int step = 0; // 0 البريد، 1 الرمز، 2 كلمة جديدة، 3 تم
  bool hidePass = true;
  int secondsLeft = 0;

  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmController = TextEditingController();
  final codeControllers = List.generate(
    codeLength,
    (_) => TextEditingController(),
  );
  final codeFocus = List.generate(codeLength, (_) => FocusNode());

  Timer? _timer;

  String get code => codeControllers.map((c) => c.text).join();
  bool get isCodeComplete => code.length == codeLength;

  String get maskedEmail {
    final email = emailController.text;
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].length <= 3) return email;
    return '${parts[0].substring(0, 3)}***@${parts[1]}';
  }

  // ---------- عداد إعادة الإرسال ----------
  void _startTimer() {
    _timer?.cancel();
    secondsLeft = resendSeconds;
    update();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft == 0) {
        t.cancel();
      } else {
        secondsLeft--;
        update();
      }
    });
  }

  // ---------- التنقل بين الخطوات ----------
  String? emailError;

  void sendCode() {
    emailError = Validators.email(emailController.text);
    if (emailError != null) {
      update();
      return;
    }
    if (!requireOnline()) return;
    // هنا بعدين: تنادي الـ API عشان يرسل الرمز للإيميل
    step = 1;
    update();
    _startTimer();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!isClosed) codeFocus[0].requestFocus();
    });
  }

  void onCodeChanged(int i, String value) {
    if (value.isNotEmpty && i < codeLength - 1) {
      codeFocus[i + 1].requestFocus(); // ينتقل للخانة الجاية
    } else if (value.isEmpty && i > 0) {
      codeFocus[i - 1].requestFocus(); // يرجع لو مسح
    }
    update(); // عشان زر التأكيد يتفعّل لما الرمز يكمل
  }

  void resendCode() {
    // هنا بعدين: تنادي الـ API تاني
    for (final c in codeControllers) {
      c.clear();
    }
    codeFocus[0].requestFocus();
    _startTimer();
  }

  void verifyCode() {
    // هنا بعدين: تتأكد من الرمز مع الـ API
    step = 2;
    update();
  }

  void togglePass() {
    hidePass = !hidePass;
    update();
  }

  void savePassword() {
    // هنا بعدين: ترسل كلمة المرور الجديدة للـ API
    step = 3;
    update();
  }

  void back() {
    step--;
    update();
  }

  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    passController.dispose();
    confirmController.dispose();
    for (final c in codeControllers) {
      c.dispose();
    }
    for (final f in codeFocus) {
      f.dispose();
    }
    super.onClose();
  }
}

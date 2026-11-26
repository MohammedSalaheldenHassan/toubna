import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/services/app_storage.dart';

/// لغة التطبيق (العربية افتراضيًا). التبديل بيقلب الاتجاه (RTL/LTR)
/// ويتحفظ على الجهاز.
class LocaleController extends GetxController {
  static const arabic = Locale('ar');
  static const english = Locale('en');
  static const supported = [arabic, english];

  final locale = arabic.obs;

  LocaleController([Locale initial = arabic]) {
    locale.value = initial;
  }

  bool get isArabic => locale.value.languageCode == 'ar';

  Future<void> change(Locale value) async {
    if (value == locale.value) return;
    locale.value = value;
    Get.locale = value;
    _rebuildApp();
    await AppStorage.setLanguage(value.languageCode);
  }

  Future<void> toggle() => change(isArabic ? english : arabic);

  /// يعيد بناء كل الشاشات (حتى اللي في الخلفية) عشان كل `.tr` تتحسب
  /// باللغة الجديدة — من غير ما نفقد مكان المستخدمة أو حالة الصفحات.
  static void _rebuildApp() {
    void mark(Element element) {
      element.markNeedsBuild();
      element.visitChildren(mark);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(mark);
  }
}

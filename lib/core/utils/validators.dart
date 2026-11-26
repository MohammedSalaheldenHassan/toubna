import 'package:get/get.dart';

/// قواعد التحقق المشتركة (الدخول، التسجيل، العناوين...).
/// كل دالة ترجع رسالة الخطأ (مترجمة) أو null لو القيمة سليمة.
abstract final class Validators {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  /// أرقام سودانية: 9XXXXXXXX أو 1XXXXXXXX مع +249 أو 0 اختياريًا.
  static final _sudanPhone = RegExp(r'^(\+?249|0)?[19]\d{8}$');

  static const minPassword = 8;

  static String? name(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'اكتبي اسمك الكامل'.tr;
    if (v.length < 3) return 'الاسم قصير جدًا'.tr;
    return null;
  }

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'اكتبي البريد الإلكتروني'.tr;
    if (!_email.hasMatch(v)) return 'البريد الإلكتروني غير صحيح'.tr;
    return null;
  }

  static String? phone(String? value) {
    final digits = normalizePhone(value);
    if (digits.isEmpty) return 'اكتبي رقم الموبايل'.tr;
    if (!_sudanPhone.hasMatch(digits)) {
      return 'رقم غير صحيح، مثال: 912345678'.tr;
    }
    return null;
  }

  /// كلمة مرور التسجيل: 8 أحرف على الأقل، فيها حرف ورقم.
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'اكتبي كلمة المرور'.tr;
    if (v.length < minPassword) {
      return 'كلمة المرور لازم تكون @p0 أحرف على الأقل'.trParams({
        'p0': '$minPassword',
      });
    }
    if (!RegExp(r'[A-Za-z؀-ۿ]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'كلمة المرور لازم يكون فيها حروف وأرقام'.tr;
    }
    return null;
  }

  /// كلمة مرور الدخول: بس ما تكون فاضية.
  static String? password(String? value) =>
      (value ?? '').isEmpty ? 'اكتبي كلمة المرور'.tr : null;

  static String? confirm(String? value, String password) {
    if ((value ?? '').isEmpty) return 'أكّدي كلمة المرور'.tr;
    if (value != password) return 'كلمتا المرور غير متطابقتين'.tr;
    return null;
  }

  static String normalizePhone(String? value) =>
      (value ?? '').replaceAll(RegExp(r'[\s-]'), '');

  /// "0912345678" / "912345678" / "+249912345678" → "+249 912 345 678"
  static String formatSudanPhone(String value) {
    var d = normalizePhone(value).replaceFirst('+', '');
    if (d.startsWith('249')) d = d.substring(3);
    if (d.startsWith('0')) d = d.substring(1);
    if (d.length != 9) return value.trim();
    return '+249 ${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6)}';
  }
}

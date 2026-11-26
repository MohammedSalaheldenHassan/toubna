import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// تخزين بسيط على الجهاز (إعدادات وحالات تفضل بعد قفل التطبيق).
///
/// هنا لاحقًا: توكن تسجيل الدخول يتخزّن بـ flutter_secure_storage
/// (مش هنا) لأنه بيانات حساسة.
abstract final class AppStorage {
  static const _onboardingSeen = 'onboarding_seen';
  static const _language = 'language';

  // مفاتيح بيانات المستخدمة (بتتمسح مع حذف الحساب)
  static const cartKey = 'cart_v1';
  static const favoritesKey = 'favorites_v1';
  static const notificationsKey = 'notifications_on';
  static const avatarKey = 'avatar_path';
  static const userDataKeys = [
    cartKey,
    favoritesKey,
    notificationsKey,
    avatarKey,
  ];

  /// يقرأ قيمة JSON محفوظة (أو null لو ما موجودة / تالفة).
  static Future<Object?> readJson(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      return raw == null ? null : jsonDecode(raw);
    } catch (_) {
      return null; // بيانات تالفة أو تخزين مش متاح → نبدأ من جديد
    }
  }

  static Future<void> writeJson(String key, Object? value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(value));
    } catch (_) {
      // التخزين مش متاح — البيانات تفضل في الذاكرة بس
    }
  }

  static Future<bool?> readBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {}
  }

  static Future<String?> readString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeString(String key, String? value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      value == null
          ? await prefs.remove(key)
          : await prefs.setString(key, value);
    } catch (_) {}
  }

  /// يمسح بيانات المستخدمة (السلة، المفضلة، الإعدادات) ويحتفظ باللغة
  /// والـ onboarding — بيتنادى مع حذف الحساب.
  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in userDataKeys) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }

  /// كود اللغة المحفوظ (ar / en)، أو null لو ما اتختارت.
  static Future<String?> language() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_language);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setLanguage(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_language, code);
    } catch (_) {
      // التخزين مش متاح (مثلاً في الاختبارات بدون mock) — اللغة تتغير بس ما تتحفظ
    }
  }

  static Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeen) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeen, true);
  }
}

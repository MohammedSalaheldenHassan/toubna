import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toubna/core/utils/app_message.dart';
import 'package:url_launcher/url_launcher.dart';

/// يفتح اتصال/واتساب/إيميل. لو الجهاز ما قدر (مثلاً مافي تطبيق إيميل)
/// بننسخ القيمة ونقول للمستخدمة.
Future<void> openExternal(Uri uri, {required String copyValue}) async {
  var opened = false;
  try {
    // timeout: لو الجهاز ما رد (مثلاً الـ plugin مش متاح) ما يفضل الزر معلّق
    opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    ).timeout(const Duration(seconds: 3), onTimeout: () => false);
  } catch (_) {
    opened = false;
  }
  if (!opened) {
    await Clipboard.setData(ClipboardData(text: copyValue));
    showAppMessage('ما قدرنا نفتحها، فنسخنا: @p0'.trParams({'p0': copyValue}));
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// خط الاختبارات الافتراضي يرسم كل حرف كمربع كامل، فبنحمّل خطوط التطبيق
/// الحقيقية (IBM Plex Sans Arabic و Reem Kufi) عشان قياس الـ overflow يكون
/// نفس اللي على الجهاز. DejaVu Sans احتياطي لأي نص بدون خط محدد.
const _families = {
  'IBMPlexSansArabic': [
    'assets/fonts/IBMPlexSansArabic-Regular.ttf',
    'assets/fonts/IBMPlexSansArabic-Medium.ttf',
    'assets/fonts/IBMPlexSansArabic-SemiBold.ttf',
    'assets/fonts/IBMPlexSansArabic-Bold.ttf',
  ],
  'ReemKufi': ['assets/fonts/ReemKufi-Variable.ttf'],
  'Roboto': [
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
  ],
};

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final MapEntry(key: family, value: files) in _families.entries) {
    final available = files.where((f) => File(f).existsSync()).toList();
    if (available.isEmpty) continue;
    final loader = FontLoader(family);
    for (final path in available) {
      loader.addFont(
        Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
      );
    }
    await loader.load();
  }
  await testMain();
}

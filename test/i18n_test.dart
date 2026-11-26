import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/i18n/app_translations.dart';
import 'package:toubna/core/i18n/locale_controller.dart';
import 'package:toubna/core/i18n/plural.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/app_storage.dart';
import 'package:toubna/core/widgets/shimmer.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';
import 'package:toubna/features/my_order/data/order_models.dart';
import 'package:toubna/features/routes/main_shell_controller.dart';
import 'package:toubna/main.dart';

/// نصوص عربية في الكود مقصود ما تتترجم (أسماء أشخاص، أنماط بحث، ...).
const _untranslated = {
  '[أإآ]', 'ا', 'ة', 'ه', 'ى', 'ي', '[ً-ْ]', // توحيد الحروف في البحث
  'صلاح الدين حسن مهدي', 'صلاح الدين حسن', 'عثمان الطيب', // أسماء أشخاص
  'م', // أول حرف في الصورة الرمزية
  'العربية', // اسم اللغة بيظهر بلغته
  '[A-Za-z؀-ۿ]', // نطاق حروف في التحقق من كلمة المرور
};

final _arabic = RegExp(r'[؀-ۿ]');
// '...' أو "..." (مع دعم \' و \n جوه النص)
final _literal = RegExp(
  r"'((?:[^'\\\n]|\\.)*)'"
  '|'
  r'"((?:[^"\\\n]|\\.)*)"',
);

/// كل النصوص العربية في lib (من غير التعليقات وملف الترجمة وملف الجمع).
Set<String> _arabicLiterals() {
  final keys = <String>{};
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('app_translations.dart'))
      .where((f) => !f.path.endsWith('plural.dart'));
  for (final file in files) {
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('//')) continue;
      final code = line.split(' // ').first;
      for (final m in _literal.allMatches(code)) {
        final raw = m.group(1) ?? m.group(2)!;
        if (!_arabic.hasMatch(raw) || raw.contains(r'$')) continue;
        keys.add(raw.replaceAll(r'\n', '\n').replaceAll(r"\'", "'"));
      }
    }
  }
  return keys;
}

Future<void> _useScreen(
  WidgetTester tester,
  Size size, {
  double text = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = text;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _startApp(WidgetTester tester, {Locale? locale}) async {
  SharedPreferences.setMockInitialValues({'onboarding_seen': true});
  Get.reset();
  Get.testMode = true;
  await tester.pumpWidget(MyApp(locale: locale));
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

TextDirection _direction(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(Scaffold).last));

void main() {
  test('every Arabic text in the code has an English translation', () {
    final en = AppTranslations().keys['en']!;
    final missing = [
      for (final key in _arabicLiterals())
        if (!en.containsKey(key) && !_untranslated.contains(key)) key,
    ];
    expect(missing, isEmpty, reason: 'نصوص بدون ترجمة إنجليزية');
  });

  test('English templates keep the same @placeholders', () {
    final en = AppTranslations().keys['en']!;
    final placeholder = RegExp(r'@\w+');
    for (final MapEntry(:key, :value) in en.entries) {
      final ar = placeholder.allMatches(key).map((m) => m[0]).toSet();
      final eng = placeholder.allMatches(value).map((m) => m[0]).toSet();
      expect(eng, ar, reason: key);
      expect(value.trim(), isNotEmpty, reason: key);
      expect(_arabic.hasMatch(value) && key != 'العربية', isFalse, reason: key);
    }
  });

  test('every product fabric type is translated', () {
    final en = AppTranslations().keys['en']!;
    for (final p in Products.all) {
      expect(en.containsKey(p.kindKey), isTrue, reason: p.kindKey);
      expect(en.containsKey(p.nameKey), isTrue, reason: p.nameKey);
    }
  });

  testWidgets('switch to English from Account: texts, LTR, saved, and back', (
    tester,
  ) async {
    await _useScreen(tester, const Size(412, 915));
    await _startApp(tester);
    Get.offAllNamed(AppRoutes.main);
    await tester.pumpAndSettle();
    final shell = Get.find<MainShellController>();
    expect(_direction(tester), TextDirection.rtl);

    // من حسابي → English
    shell.changeTab(4);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(Get.locale?.languageCode, 'en');
    expect(await AppStorage.language(), 'en');
    expect(_direction(tester), TextDirection.ltr);
    expect(find.text('Account'), findsWidgets); // الشريط السفلي + العنوان
    expect(find.text('My addresses'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);

    // الرئيسية بالإنجليزي: العناوين والأسعار
    shell.changeTab(0);
    await tester.pumpAndSettle();
    expect(find.text('Best sellers'), findsOneWidget);
    expect(find.text('New arrivals'), findsOneWidget);
    expect(find.textContaining('SDG '), findsWidgets);
    expect(find.text('الأكثر مبيعًا'), findsNothing);

    // صفحة منتج: الاسم والنوع والوصف بالإنجليزي
    final product = Products.byId('chiffon-1')!;
    Get.toNamed(AppRoutes.product, arguments: product.id);
    await tester.pumpAndSettle();
    expect(find.text(product.name), findsOneWidget);
    expect(product.name, isNot(product.nameKey));
    expect(find.text('Add to cart'), findsOneWidget);
    expect(find.textContaining('Colour: ', findRichText: true), findsOneWidget);
    Get.back();
    await tester.pumpAndSettle();

    // السلة: الجمع بالإنجليزي، والمنتج يتحفظ بالمفتاح العربي
    final cart = Get.find<CartController>();
    cart.addProduct(Products.byId('chiffon-5')!);
    cart.addProduct(Products.byId('silk-2')!);
    shell.changeTab(MainShellController.cartTab);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text(itemsText(cart.count)), findsOneWidget);
    expect(itemsText(2), '2 items');
    expect(find.text('Checkout'), findsOneWidget);
    expect(_arabic.hasMatch(cart.items.first.nameKey), isTrue);

    // الطلبات: الحالة والتاريخ بالإنجليزي
    shell.changeTab(MainShellController.ordersTab);
    await tester.pumpAndSettle();
    expect(find.text('Preparing'), findsWidgets);
    expect(find.text('Today, 7:45 PM'), findsOneWidget);
    expect(OrderStatus.delivered.label, 'Delivered');

    // الرجوع للعربي: كل حاجة ترجع RTL وعربي
    shell.changeTab(4);
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(Get.locale?.languageCode, 'ar');
    expect(await AppStorage.language(), 'ar');
    expect(_direction(tester), TextDirection.rtl);
    expect(find.text('حسابي'), findsWidgets);
    expect(itemsText(2), 'منتجان');
  });

  testWidgets('onboarding language chip switches to English', (tester) async {
    await _useScreen(tester, const Size(412, 915));
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.onboarding);
    expect(find.text('كل التياب في مكان واحد'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Every toub in one place'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget); // الزرار بقى يرجّع للعربي
    expect(Get.find<LocaleController>().isArabic, isFalse);
  });

  testWidgets('app starts in the saved language', (tester) async {
    await _useScreen(tester, const Size(412, 915));
    await _startApp(tester, locale: LocaleController.english);
    expect(Get.currentRoute, AppRoutes.login);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);
    expect(_direction(tester), TextDirection.ltr);
  });

  // الإنجليزي غالبًا أطول من العربي — نتأكد إن ما في overflow في أي صفحة
  for (final (name, size, text) in [
    ('small 320x568', const Size(320, 568), 1.0),
    ('compact 360x640 + large text', const Size(360, 640), 1.3),
    ('tablet 800x1280', const Size(800, 1280), 1.0),
  ]) {
    testWidgets('English: all screens lay out without overflow on $name', (
      tester,
    ) async {
      await _useScreen(tester, size, text: text);
      await _startApp(tester, locale: LocaleController.english);

      Future<void> visit(String route, {Object? arguments}) async {
        Get.toNamed(route, arguments: arguments);
        await _pumpFrames(tester);
        await tester.pumpAndSettle();
        expect(find.byType(Shimmer), findsNothing, reason: route);
        Get.back();
        await tester.pumpAndSettle();
      }

      Get.offAllNamed(AppRoutes.onboarding);
      await tester.pumpAndSettle();
      Get.offAllNamed(AppRoutes.register);
      await tester.pumpAndSettle();
      Get.offAllNamed(AppRoutes.login);
      await tester.pumpAndSettle();
      Get.offAllNamed(AppRoutes.main);
      await tester.pumpAndSettle();
      final shell = Get.find<MainShellController>();
      for (var tab = 0; tab < 5; tab++) {
        shell.changeTab(tab);
        await tester.pumpAndSettle();
      }
      Get.find<CartController>().clear();
      shell.changeTab(MainShellController.cartTab);
      await tester.pumpAndSettle();

      for (final c in Catalog.all) {
        await visit(AppRoutes.category, arguments: c.id);
      }
      await visit(AppRoutes.product, arguments: 'garmasis-0');
      await visit(AppRoutes.search);
      for (final o in [...MockOrders.current, ...MockOrders.past]) {
        Get.toNamed(AppRoutes.trackOrder, arguments: o.number);
        await _pumpFrames(tester);
        Get.back();
        await _pumpFrames(tester);
        await tester.pumpAndSettle();
      }
      for (final route in [
        AppRoutes.editProfile,
        AppRoutes.locations,
        AppRoutes.addressForm,
        AppRoutes.favorites,
        AppRoutes.notifications,
        AppRoutes.contactUs,
        AppRoutes.terms,
      ]) {
        await visit(route);
      }
      await visit(
        AppRoutes.verifyPhone,
        arguments: {
          'name': 'Mariam',
          'email': 'm@x.com',
          'phone': '+249 912 345 678',
        },
      );
      // رسالة "رمز التجربة" ليها مؤقت — نخليها تخلص قبل نهاية الاختبار
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  }
}

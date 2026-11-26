import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/app_storage.dart';
import 'package:toubna/core/services/connectivity_service.dart';
import 'package:toubna/core/services/favorites_controller.dart';
import 'package:toubna/core/services/user_controller.dart';
import 'package:toubna/core/widgets/error_state_view.dart';
import 'package:toubna/features/addresses/presentation/controllers/addresses_controller.dart';
import 'package:toubna/features/auth/register/presentation/widgets/term.dart';
import 'package:toubna/features/auth/verify_phone/verify_phone_controller.dart';
import 'package:toubna/features/cart/data/cart_item.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';
import 'package:toubna/features/my_order/presentation/controllers/my_order_controller.dart';
import 'package:toubna/features/notifications/notifications_controller.dart';
import 'package:toubna/features/routes/main_shell_controller.dart';
import 'package:toubna/main.dart';

Future<void> _useScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(412, 915);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// يشغّل التطبيق (بعد الـ splash) مع بيانات محفوظة اختيارية.
Future<void> _startApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues({'onboarding_seen': true, ...prefs});
  Get.reset();
  Get.testMode = true;
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Future<void> _goMain(WidgetTester tester) async {
  Get.offAllNamed(AppRoutes.main);
  await tester.pumpAndSettle();
}

/// يخلّي الرسائل (snackbar) تخلص عشان ما يفضل مؤقت شغال.
Future<void> _flushMessages(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

/// يلتقط أي نص بيتنسخ (Clipboard) أو رابط بيتفتح.
String? _copied;
void _mockPlatform(WidgetTester tester) {
  _copied = null;
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        _copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
}

void main() {
  group('saved on device', () {
    testWidgets('cart and favorites are saved on every change', (tester) async {
      await _useScreen(tester);
      await _startApp(tester);
      await _goMain(tester);
      final cart = Get.find<CartController>();
      final favorites = Get.find<FavoritesController>();
      await cart.ready;
      await favorites.ready;
      expect(cart.isEmpty, isTrue); // أول تشغيل: سلة فاضية
      expect(favorites.count, 0);

      final p = Products.byId('silk-3')!;
      cart.add(CartItem.fromProduct(p, qty: 2), notify: false);
      favorites.toggle(p);
      await tester.pump();

      final savedCart = await AppStorage.readJson(AppStorage.cartKey) as Map;
      expect((savedCart['items'] as List).single['id'], 'silk-3');
      expect((savedCart['items'] as List).single['qty'], 2);
      expect(await AppStorage.readJson(AppStorage.favoritesKey), ['silk-3']);
    });

    testWidgets('cart, coupon and favorites come back after reopening', (
      tester,
    ) async {
      await _useScreen(tester);
      final item = CartItem.fromProduct(Products.byId('chiffon-2')!, qty: 3);
      await _startApp(
        tester,
        prefs: {
          AppStorage.cartKey: jsonEncode({
            'items': [item.toJson()],
            'coupon': 'TOUBNA10',
          }),
          AppStorage.favoritesKey: jsonEncode(['swiss-1', 'gone-999']),
        },
      );
      final cart = Get.find<CartController>();
      final favorites = Get.find<FavoritesController>();
      await cart.ready;
      await favorites.ready;
      expect(cart.count, 3);
      expect(cart.items.single.name, item.name);
      expect(cart.couponCode.value, 'TOUBNA10');
      // المنتج اللي اتحذف من الكتالوج بيتجاهل
      expect(favorites.ids, {'swiss-1'});
    });

    testWidgets('broken saved data does not crash — starts empty', (
      tester,
    ) async {
      await _useScreen(tester);
      await _startApp(
        tester,
        prefs: {
          AppStorage.cartKey: '{not json',
          AppStorage.favoritesKey: jsonEncode({'oops': 1}),
        },
      );
      await Get.find<CartController>().ready;
      await Get.find<FavoritesController>().ready;
      expect(Get.find<CartController>().isEmpty, isTrue);
      expect(Get.find<FavoritesController>().count, 0);
    });
  });

  group('no internet', () {
    testWidgets('banner, error screen, auto-retry when back online', (
      tester,
    ) async {
      await _useScreen(tester);
      await _startApp(tester);
      await _goMain(tester);
      final connectivity = Get.find<ConnectivityService>();

      connectivity.setOnline(false);
      await tester.pumpAndSettle();
      expect(find.text('أنتِ غير متصلة بالإنترنت'), findsOneWidget);

      // صفحة قسم وهي offline: شاشة خطأ مع "حاولي تاني"
      Get.toNamed(AppRoutes.category, arguments: 'foal');
      await tester.pumpAndSettle();
      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.text('مافي اتصال بالإنترنت'), findsOneWidget);
      await tester.tap(find.text('حاولي تاني'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorStateView), findsOneWidget); // لسه offline

      // الاتصال رجع: الشريط يقول "رجع الاتصال" والصفحة تتحمّل لوحدها
      connectivity.setOnline(true);
      await tester.pump();
      expect(find.text('رجع الاتصال'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorStateView), findsNothing);
      expect(find.text('رجع الاتصال'), findsNothing);
      expect(find.text('فوال'), findsWidgets);
    });

    testWidgets('actions that need internet are blocked with a message', (
      tester,
    ) async {
      await _useScreen(tester);
      await _startApp(tester);
      await _goMain(tester);
      final cart = Get.find<CartController>();
      final orders = Get.find<MyOrderController>();
      cart.add(CartItem.fromProduct(Products.byId('foal-1')!), notify: false);
      final before = orders.currentOrders.length;

      Get.find<ConnectivityService>().setOnline(false);
      await tester.pumpAndSettle();
      cart.confirmCheckout();
      await tester.pump();
      expect(find.textContaining('مافي اتصال بالإنترنت.'), findsOneWidget);
      expect(orders.currentOrders.length, before);
      expect(cart.isEmpty, isFalse);

      Get.find<ConnectivityService>().setOnline(true);
      await _flushMessages(tester);
    });
  });

  group('register + phone verification', () {
    testWidgets('invalid fields show errors and stay on register', (
      tester,
    ) async {
      await _useScreen(tester);
      await _startApp(tester);
      Get.toNamed(AppRoutes.register);
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'م');
      await tester.enterText(fields.at(1), 'not-an-email');
      await tester.enterText(fields.at(2), '123');
      await tester.enterText(fields.at(3), 'short');
      await tester.enterText(fields.at(4), 'other');
      await tester.ensureVisible(find.text(' إنشاء الحساب'));
      await tester.tap(find.text(' إنشاء الحساب'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.register);
      expect(find.text('الاسم قصير جدًا'), findsOneWidget);
      expect(find.text('البريد الإلكتروني غير صحيح'), findsOneWidget);
      expect(find.text('رقم غير صحيح، مثال: 912345678'), findsOneWidget);
      expect(
        find.text('كلمة المرور لازم تكون 8 أحرف على الأقل'),
        findsOneWidget,
      );
      expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
    });

    testWidgets('valid form → code screen → wrong code → right code → home', (
      tester,
    ) async {
      await _useScreen(tester);
      await _startApp(tester);
      Get.toNamed(AppRoutes.register);
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'مريم أحمد');
      await tester.enterText(fields.at(1), 'mariam@example.com');
      await tester.enterText(fields.at(2), '0912345678');
      await tester.enterText(fields.at(3), 'toub2026');
      await tester.enterText(fields.at(4), 'toub2026');
      // بدون الموافقة على الشروط ما يكمل
      await tester.ensureVisible(find.text(' إنشاء الحساب'));
      await tester.tap(find.text(' إنشاء الحساب'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.register);
      await _flushMessages(tester);

      // خانة الموافقة نفسها (الكلمات الملونة جواها روابط للشروط)
      await tester.tap(
        find.descendant(
          of: find.byType(Term),
          matching: find.byType(AnimatedContainer),
        ),
      );
      await tester.pump();
      await tester.tap(find.text(' إنشاء الحساب'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.verifyPhone);
      final c = Get.find<VerifyPhoneController>();
      expect(c.phone, '+249 912 345 678');
      expect(find.text('+249 912 345 678'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(c.secondsLeft.value, greaterThan(50));

      // رمز غلط → رسالة وعدد المحاولات يقل
      await tester.enterText(find.byType(TextField), '0000');
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.verifyPhone);
      expect(c.attemptsLeft.value, VerifyPhoneController.maxAttempts - 1);
      expect(find.text('الرمز غير صحيح — باقي 4 محاولات'), findsOneWidget);

      // إعادة الإرسال بعد ما العداد يخلص
      expect(find.text('ما وصلك؟ إعادة الإرسال'), findsNothing);
      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ما وصلك؟ إعادة الإرسال'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(c.secondsLeft.value, greaterThan(50));
      expect(c.attemptsLeft.value, VerifyPhoneController.maxAttempts);

      // الرمز الصح → الحساب يتعمل والبيانات تتحفظ
      await tester.enterText(
        find.byType(TextField),
        VerifyPhoneController.demoCode,
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.main);
      final user = Get.find<UserController>();
      expect(user.name.value, 'مريم أحمد');
      expect(user.phone.value, '+249 912 345 678');
      expect(user.email.value, 'mariam@example.com');
      await _flushMessages(tester);
    });

    testWidgets('too many wrong codes locks until a new code', (tester) async {
      await _useScreen(tester);
      await _startApp(tester);
      Get.toNamed(
        AppRoutes.verifyPhone,
        arguments: {
          'name': 'م',
          'email': 'a@b.co',
          'phone': '+249 912 345 678',
        },
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final c = Get.find<VerifyPhoneController>();
      for (var i = 0; i < VerifyPhoneController.maxAttempts; i++) {
        c.codeController.text = '9999';
        c.verify(); // بدون await: الانتظار جواها بيخلص مع pump
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();
      expect(c.locked, isTrue);
      expect(find.text('محاولات كتيرة غلط. اطلبي رمز جديد.'), findsOneWidget);
      // الرجوع يقفل الصفحة (ويوقف العداد)
      Get.back();
      await _flushMessages(tester);
      expect(Get.isRegistered<VerifyPhoneController>(), isFalse);
    });
  });

  testWidgets('delete account: needs password + confirmation, clears data', (
    tester,
  ) async {
    await _useScreen(tester);
    await _startApp(tester);
    await _goMain(tester);
    final cart = Get.find<CartController>();
    final favorites = Get.find<FavoritesController>();
    final p = Products.byId('swiss-2')!;
    cart.add(CartItem.fromProduct(p), notify: false);
    favorites.toggle(p);
    await tester.pump();

    Get.toNamed(AppRoutes.editProfile);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('حذف الحساب'));
    await tester.tap(find.text('حذف الحساب'));
    await tester.pumpAndSettle();
    expect(find.text('حذف الحساب نهائيًا'), findsOneWidget);

    // الزرار مقفول لحد كلمة المرور + التأكيد
    await tester.tap(find.text('حذف حسابي'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, isNot(AppRoutes.login));

    await tester.enterText(find.byType(TextField).last, 'secret123');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.ensureVisible(find.text('حذف حسابي'));
    await tester.tap(find.text('حذف حسابي'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.login);
    expect(
      find.text('تم حذف حسابك. نتمنى نشوفك تاني في توبنا.'),
      findsOneWidget,
    );
    expect(cart.isEmpty, isTrue);
    expect(favorites.count, 0);
    expect(Get.find<AddressesController>().count, 0);
    final savedCart = await AppStorage.readJson(AppStorage.cartKey);
    expect(savedCart == null || (savedCart as Map)['items'].isEmpty, isTrue);
    expect(
      await AppStorage.readJson(AppStorage.favoritesKey),
      anyOf(isNull, isEmpty),
    );
    // اللغة والـ onboarding ما بيتمسحوا
    expect(await AppStorage.isOnboardingSeen(), isTrue);
    await _flushMessages(tester);
  });

  testWidgets('notifications: bell, open one, mark all read, turn off', (
    tester,
  ) async {
    await _useScreen(tester);
    await _startApp(tester);
    await _goMain(tester);
    final n = Get.find<NotificationsController>();
    final unread = n.unreadCount;
    expect(unread, greaterThan(0));

    await tester.tap(find.byTooltip('الإشعارات'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.notifications);

    // الإشعار يفتح القسم بتاعه ويتعلّم كمقروء
    await tester.tap(find.text('خصم حتى 30٪ على القرمصيص'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.category);
    expect(n.unreadCount, unread - 1);
    Get.back();
    await tester.pumpAndSettle();

    await tester.tap(find.text('قراءة الكل'));
    await tester.pumpAndSettle();
    expect(n.unreadCount, 0);
    expect(find.text('قراءة الكل'), findsNothing);

    // قفل الإشعارات من حسابي بيتحفظ وبيظهر تنبيه
    await n.setEnabled(false);
    await tester.pumpAndSettle();
    expect(await AppStorage.readBool(AppStorage.notificationsKey), isFalse);
    expect(
      find.text('الإشعارات مقفولة، فما هتوصلك تنبيهات الطلبات والعروض.'),
      findsOneWidget,
    );
    await tester.tap(find.text('تفعيل'));
    await tester.pumpAndSettle();
    expect(n.enabled.value, isTrue);
  });

  testWidgets('every former dead button now does something', (tester) async {
    await _useScreen(tester);
    _mockPlatform(tester);
    await _startApp(tester);

    // روابط الشروط في الدخول
    await tester.tap(
      find.textContaining('الشروط والأحكام', findRichText: true),
    );
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.terms);
    expect(find.text('سياسة الخصوصية'), findsWidgets);
    Get.back();
    await tester.pumpAndSettle();

    // أيقونة البحث في الأقسام
    await _goMain(tester);
    Get.find<MainShellController>().changeTab(1);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('بحث'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.search);
    Get.back();
    await tester.pumpAndSettle();

    // تواصلي معنا: الأزرار بتفتح (أو بتنسخ لو ما قدرت)
    Get.toNamed(AppRoutes.contactUs);
    await tester.pumpAndSettle();
    await tester.tap(find.text('واتساب'));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(_copied, isNotNull);
    await tester.tap(find.text('كيف أدفع؟'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'الدفع عند الاستلام: نقدًا أو بتحويل بنكك للمندوب لما يوصلك الطلب.',
      ),
      findsOneWidget,
    );
    await _flushMessages(tester);
    Get.back();
    await tester.pumpAndSettle();

    // الملف الشخصي: زر الكاميرا يفتح الخيارات، والحقول المقفولة بتشرح
    Get.toNamed(AppRoutes.editProfile);
    await tester.pumpAndSettle();
    final camera = find.byWidgetPredicate(
      (w) => w is ImageIcon && '${w.image}'.contains('camera'),
    );
    await tester.tap(camera);
    await tester.pumpAndSettle();
    expect(find.text('اختاري من المعرض'), findsOneWidget);
    expect(find.text('صوّري بالكاميرا'), findsOneWidget);
    // المعرض بيرفض (زي لو الصلاحية مقفولة) → رسالة واضحة بدل crash
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/image_picker'),
      (call) async => throw PlatformException(code: 'photo_access_denied'),
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/image_picker'),
        null,
      ),
    );
    await tester.tap(find.text('اختاري من المعرض'));
    await tester.pumpAndSettle();
    expect(
      find.text('ما قدرنا نفتح الصور. اتأكدي من الصلاحيات وحاولي تاني.'),
      findsOneWidget,
    );
    await _flushMessages(tester);
    await tester.tap(find.text('mohammedsalah@gmail.com'));
    await tester.pump();
    expect(
      find.text('رقم الموبايل والبريد مربوطين بحسابك. لتغييرهم تواصلي معنا.'),
      findsOneWidget,
    );
    await _flushMessages(tester);

    // الصورة المختارة بتتحفظ
    await Get.find<UserController>().setAvatar('/tmp/me.jpg');
    expect(await AppStorage.readString(AppStorage.avatarKey), '/tmp/me.jpg');
  });

  testWidgets('courier can be called or copied from tracking', (tester) async {
    await _useScreen(tester);
    _mockPlatform(tester);
    await _startApp(tester);
    await _goMain(tester);
    Get.toNamed(AppRoutes.trackOrder, arguments: '#TB-20455');
    await _pumpFrames(tester);
    await tester.tap(find.byTooltip('اتصلي بالمندوب'));
    await tester.pump(const Duration(seconds: 4));
    await _pumpFrames(tester);
    // مافي تطبيق اتصال في الاختبار → الرقم بيتنسخ
    expect(_copied, '+249 91 234 5678');
    await tester.pump(const Duration(seconds: 5));
    Get.back();
    await _pumpFrames(tester);
    await tester.pumpAndSettle();
  });
}

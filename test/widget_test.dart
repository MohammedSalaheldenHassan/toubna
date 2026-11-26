import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toubna/core/data/app_images.dart';
import 'package:toubna/core/services/app_storage.dart';
import 'package:toubna/features/detail/presentation/controllers/product_controller.dart';
import 'package:toubna/features/onboarding/onboarding_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/favorites_controller.dart';
import 'package:toubna/core/widgets/product_card.dart';
import 'package:toubna/core/widgets/shimmer.dart';
import 'package:toubna/core/widgets/skeletons.dart';
import 'package:toubna/features/addresses/data/address.dart';
import 'package:toubna/features/addresses/presentation/controllers/addresses_controller.dart';
import 'package:toubna/features/cart/data/cart_item.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';
import 'package:toubna/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:toubna/features/categories/presentation/controllers/category_products_controller.dart';
import 'package:toubna/features/home/presentation/controllers/home_controller.dart';
import 'package:toubna/features/search/presentation/controllers/product_search_controller.dart';
import 'package:toubna/features/auth/login/presentation/widgets/forget_password.dart';
import 'package:toubna/features/auth/login/presentation/controllers/forgot_password_controller.dart';
import 'package:toubna/features/my_order/data/order_models.dart';
import 'package:toubna/features/my_order/presentation/controllers/my_order_controller.dart';
import 'package:toubna/features/my_order/presentation/controllers/track_order_controller.dart';
import 'package:toubna/features/routes/main_shell_controller.dart';
import 'package:toubna/main.dart';

/// مقاسات نتحقق عليها إن مافي أي overflow: هاتف صغير، عادي، كبير، وتابلت.
/// (المقاس، تكبير الخط من إعدادات الجهاز)
const _screens = <String, (Size, double)>{
  'small 320x568': (Size(320, 568), 1.0),
  'compact 360x640': (Size(360, 640), 1.0),
  'compact 360x640 + large text': (Size(360, 640), 1.3),
  'large 412x915': (Size(412, 915), 1.0),
  'tablet 800x1280': (Size(800, 1280), 1.0),
};

Future<void> _useScreen(
  WidgetTester tester,
  Size size, {
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _startApp(
  WidgetTester tester, {
  bool onboardingSeen = true,
}) async {
  SharedPreferences.setMockInitialValues({'onboarding_seen': onboardingSeen});
  Get.reset();
  Get.testMode = true;
  await tester.pumpWidget(const MyApp());
  // الحركة + فترة الانتظار في شاشة البداية
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

/// بعد التحميل التجريبي ما يفضل أي هيكل لامع (يعني الصفحة ما علقت).
void _expectLoaded() => expect(find.byType(Shimmer), findsNothing);

/// للصفحات اللي فيها حركة متكررة (نقطة التتبع) بدل pumpAndSettle.
Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<void> _go(WidgetTester tester, String route) async {
  Get.toNamed(route);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('splash animates then opens login', (tester) async {
    await _useScreen(tester, const Size(412, 915));
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    Get.reset();
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(Image), findsWidgets); // الشعار ظاهر من أول إطار
    expect(find.text('أهلاً بك'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('أهلاً بك'), findsOneWidget);
    expect(Get.currentRoute, AppRoutes.login);
  });

  for (final entry in _screens.entries) {
    testWidgets('all screens lay out without overflow on ${entry.key}', (
      tester,
    ) async {
      final (size, textScale) = entry.value;
      await _useScreen(tester, size, textScale: textScale);
      await _startApp(tester);

      // الـ onboarding بكل صفحاته على نفس المقاس
      Get.offAllNamed(AppRoutes.onboarding);
      await tester.pumpAndSettle();
      for (var i = 0; i < OnboardingController.pages.length; i++) {
        expect(find.text(OnboardingController.pages[i].title), findsOneWidget);
        if (i < OnboardingController.pages.length - 1) {
          await tester.tap(find.text('التالي'));
          await tester.pumpAndSettle();
        }
      }
      Get.offAllNamed(AppRoutes.login);
      await tester.pumpAndSettle();

      // الدخول + إظهار كلمة المرور
      expect(find.text('أهلاً بك'), findsOneWidget);
      await tester.tap(find.byTooltip('إظهار كلمة المرور'));
      await tester.pump();
      expect(find.byTooltip('إخفاء كلمة المرور'), findsOneWidget);

      // نسيت كلمة المرور: كل الخطوات
      ForgotPasswordSheet.show(Get.context!);
      await tester.pumpAndSettle();
      final sheet = find.byType(ForgotPasswordSheet);
      Finder inSheet(Type type) =>
          find.descendant(of: sheet, matching: find.byType(type));
      await tester.enterText(inSheet(TextFormField), 'mariam@test.com');
      await tester.tap(find.text('إرسال الرمز'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('أدخلي رمز التحقق'), findsOneWidget);
      final forgot = Get.find<ForgotPasswordController>();
      expect(forgot.isCodeComplete, isFalse);
      for (var i = 0; i < ForgotPasswordController.codeLength; i++) {
        forgot.codeControllers[i].text = '$i';
      }
      forgot.update();
      await tester.pump();
      await tester.tap(find.text('تأكيد الرمز'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('كلمة مرور جديدة'), findsOneWidget);
      Get.back(); // يقفل الشيت ويحذف الكنترولر
      await tester.pumpAndSettle();
      expect(Get.isRegistered<ForgotPasswordController>(), isFalse);

      // التسجيل: بدون موافقة على الشروط ما يكمل
      await _go(tester, AppRoutes.register);
      await tester.ensureVisible(find.text(' إنشاء الحساب'));
      await tester.tap(find.text(' إنشاء الحساب'));
      await tester.pump();
      expect(Get.currentRoute, AppRoutes.register);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // الدخول للرئيسية
      Get.offAllNamed(AppRoutes.main);
      await tester.pumpAndSettle();
      expect(find.text('الأكثر مبيعًا'), findsOneWidget);
      _expectLoaded(); // الرئيسية + طلباتي (في الـ IndexedStack)
      final shell = Get.find<MainShellController>();

      // كل تبويبات الشريط السفلي
      // سلة فيها منتجات عشان نشوف شكلها المليان
      final shellCart = Get.find<CartController>();
      for (final id in ['chiffon-5', 'accessories-2']) {
        shellCart.add(CartItem.fromProduct(Products.byId(id)!), notify: false);
      }
      for (var tab = 0; tab < 5; tab++) {
        shell.changeTab(tab);
        await tester.pumpAndSettle();
      }

      // السلة الفاضية (مع "ممكن يعجبك")
      Get.find<CartController>().clear();
      shell.changeTab(MainShellController.cartTab);
      await tester.pumpAndSettle();
      expect(find.text('سلتك فاضية'), findsOneWidget);
      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();

      // صفحة المنتج + الإضافة للسلة تحدّث العداد
      final before = Get.find<CartController>().count;
      await _go(tester, AppRoutes.product);
      _expectLoaded();
      await tester.tap(find.byTooltip('زيادة الكمية'));
      await tester.pump();
      await tester.tap(find.text('أضيفي إلى السلة'));
      await tester.pump();
      expect(Get.find<CartController>().count, before + 2);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      Get.back();
      await tester.pumpAndSettle();

      // الصفحات الفرعية
      for (final route in [
        AppRoutes.editProfile,
        AppRoutes.locations,
        AppRoutes.favorites,
        AppRoutes.contactUs,
        AppRoutes.terms,
        AppRoutes.addressForm,
      ]) {
        await _go(tester, route);
        Get.back();
        await tester.pumpAndSettle();
      }
      // نموذج تعديل عنوان (بيانات معبّاة)
      Get.toNamed(AppRoutes.addressForm, arguments: 'a1');
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();
      Get.back();
      await tester.pumpAndSettle();

      // البحث: كل المنتجات، ثم نتيجة، ثم بدون نتائج
      Get.toNamed(AppRoutes.search);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'مطرز');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'غير موجود');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.textContaining('مافي نتائج'), findsOneWidget);
      _expectLoaded();
      Get.back();
      await tester.pumpAndSettle();

      // صفحة تتبع كل طلب (حالي، في الطريق، مستلم، ملغي)
      for (final order in [...MockOrders.current, ...MockOrders.past]) {
        Get.toNamed(AppRoutes.trackOrder, arguments: order.number);
        await _pumpFrames(tester);
        expect(find.text('طلب ${order.number}'), findsOneWidget);
        _expectLoaded();
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -3000),
        );
        await _pumpFrames(tester);
        Get.back();
        await _pumpFrames(tester);
        await tester.pumpAndSettle();
      }

      // صفحة كل قسم: الفلاتر + نهاية القائمة (يبني كل الكروت)
      for (final category in Catalog.all) {
        Get.toNamed(AppRoutes.category, arguments: category.id);
        await tester.pumpAndSettle();
        expect(find.text(category.countText), findsWidgets);
        _expectLoaded();
        await tester.tap(find.text('جديد فقط'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('جديد فقط'));
        await tester.pumpAndSettle();
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -20000),
        );
        await tester.pumpAndSettle();
        Get.back();
        await tester.pumpAndSettle();
      }
    });
  }

  testWidgets('first launch: onboarding once, skip, then login/register', (
    tester,
  ) async {
    await _useScreen(tester, const Size(412, 915));
    await _startApp(tester, onboardingSeen: false);
    expect(Get.currentRoute, AppRoutes.onboarding);
    expect(find.text('كل التياب في مكان واحد'), findsOneWidget);
    expect(find.text('تخطي'), findsOneWidget);

    // السحب للصفحة الجاية (RTL: السحب لليمين)
    await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();
    expect(Get.find<OnboardingController>().page.value, 1);
    expect(find.text('اختاري لونك وطولك'), findsOneWidget);

    // تخطي → آخر صفحة فيها "ابدئي الآن" و"سجّلي دخولك"
    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();
    expect(find.text('لحد باب بيتك'), findsOneWidget);
    expect(find.text('ابدئي الآن'), findsOneWidget);
    await tester.tap(find.textContaining('سجّلي دخولك', findRichText: true));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.login);
    expect(await AppStorage.isOnboardingSeen(), isTrue);

    // "ابدئي الآن" يفتح التسجيل، والرجوع يوصّل للدخول
    Get.offAllNamed(AppRoutes.onboarding);
    await tester.pumpAndSettle();
    Get.find<OnboardingController>().skip();
    await tester.pumpAndSettle();
    await tester.tap(find.text('ابدئي الآن'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.register);
    Get.back();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.login);
  });

  testWidgets('product page shows the product that was tapped', (tester) async {
    await _useScreen(tester, const Size(412, 915));
    await _startApp(tester);
    Get.offAllNamed(AppRoutes.main);
    await tester.pumpAndSettle();
    final home = Get.find<HomeController>();
    final product = home.featuredProducts[1];

    final card = find.descendant(
      of: find.byType(ProductCard),
      matching: find.text(product.name),
    );
    await tester.ensureVisible(card.first);
    await tester.pumpAndSettle();
    await tester.tap(card.first);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.product);
    expect(Get.find<ProductController>().product.id, product.id);
    expect(find.text(product.kind), findsOneWidget);
    expect(find.text(product.priceText), findsOneWidget);

    // القلب في صفحة المنتج هو نفس المفضلة المشتركة
    final favorites = Get.find<FavoritesController>();
    final was = favorites.isFavorite(product);
    await tester.tap(find.byTooltip('المفضلة'));
    await tester.pump();
    expect(favorites.isFavorite(product), !was);

    // الإضافة للسلة بنفس اسم وسعر المنتج
    await tester.tap(find.text('أضيفي إلى السلة'));
    await tester.pump();
    final line = Get.find<CartController>().items.last;
    expect(line.name, product.name);
    expect(line.price, product.price);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  test('every content image in AppImages exists in the bundle', () async {
    for (final path in AppImages.all) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
    for (final c in Catalog.all) {
      expect(AppImages.all, contains(c.image));
    }
  });

  testWidgets('shimmer shows while loading, then content fades in', (
    tester,
  ) async {
    await _useScreen(tester, const Size(412, 915));
    await _startApp(tester);
    Get.offAllNamed(AppRoutes.main);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // أول ما الرئيسية تفتح: هيكل لامع بدل المحتوى، والموجة شغّالة
    expect(find.byType(Shimmer), findsWidgets);
    expect(find.byType(Bone), findsWidgets);
    expect(find.text('الأكثر مبيعًا'), findsNothing);
    final state = tester.state<ShimmerState>(find.byType(Shimmer).first);
    expect(state.animate, isTrue);

    await tester.pumpAndSettle();
    expect(find.byType(Shimmer), findsNothing);
    expect(find.text('الأكثر مبيعًا'), findsOneWidget);

    // صفحة قسم: الهيكل بعدين المنتجات
    Get.toNamed(AppRoutes.category, arguments: 'silk');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ProductCardSkeleton), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byType(ProductCardSkeleton), findsNothing);
    expect(find.byType(ProductCard), findsWidgets);
  });

  testWidgets('shimmer stays still when animations are disabled', (
    tester,
  ) async {
    await _useScreen(tester, const Size(412, 915));
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _startApp(tester);
    Get.offAllNamed(AppRoutes.main);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final state = tester.state<ShimmerState>(find.byType(Shimmer).first);
    expect(state.animate, isFalse);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(Shimmer), findsNothing);
  });

  testWidgets('category page filters, sorts and favorites products', (
    tester,
  ) async {
    await _useScreen(tester, const Size(412, 915));
    await _startApp(tester);

    // من كارت القسم في تبويب الأقسام
    Get.offAllNamed(AppRoutes.main);
    await tester.pumpAndSettle();
    Get.find<MainShellController>().changeTab(1);
    await tester.pumpAndSettle();
    await tester.tap(find.text('فوال'));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.category);
    final c = Get.find<CategoryProductsController>();
    expect(c.category.id, 'foal');
    expect(c.products.length, 41);

    await tester.tap(find.text('السعر: الأقل'));
    await tester.pumpAndSettle();
    final prices = c.products.map((p) => p.price).toList();
    expect(prices, [...prices]..sort());
    expect(find.text(c.products.first.priceText), findsWidgets);

    // آخر خيار يحتاج سكرول أفقي في شريط الفلاتر
    await tester.scrollUntilVisible(
      find.text('السعر: الأعلى'),
      100,
      scrollable: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axis == Axis.horizontal,
      ),
    );
    await tester.ensureVisible(find.text('السعر: الأعلى'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('السعر: الأعلى'));
    await tester.pumpAndSettle();
    expect(c.products.first.price, prices.last);

    await tester.scrollUntilVisible(
      find.text('جديد فقط'),
      -100,
      scrollable: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axis == Axis.horizontal,
      ),
    );
    await tester.ensureVisible(find.text('جديد فقط'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('جديد فقط'));
    await tester.pumpAndSettle();
    expect(c.products, isNotEmpty);
    expect(c.products.every((p) => p.isNew), isTrue);

    final first = c.products.first;
    expect(c.isFavorite(first), isFalse);
    await tester.tap(find.byType(IconButton).first);
    await tester.pump();
    expect(c.isFavorite(first), isTrue);

    // الرجوع يحذف الكنترولر، وفتح قسم تاني يبدأ من جديد
    Get.back();
    await tester.pumpAndSettle();
    expect(Get.isRegistered<CategoryProductsController>(), isFalse);
    Get.toNamed(AppRoutes.category, arguments: 'silk');
    await tester.pumpAndSettle();
    expect(Get.find<CategoryProductsController>().category.name, 'حرير');
    expect(find.text('18 منتج'), findsWidgets);
  });

  testWidgets('home: carousel, favorites, new arrivals and links', (
    tester,
  ) async {
    await _useScreen(tester, const Size(412, 915));
    await _startApp(tester);
    Get.offAllNamed(AppRoutes.main);
    await tester.pumpAndSettle();
    final home = Get.find<HomeController>();
    final favorites = Get.find<FavoritesController>();
    final shell = Get.find<MainShellController>();

    // البانر يتقلب تلقائيًا كل 5 ثواني
    expect(find.text('خصم حتى 30٪'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('تشكيلة الشيفون'), findsOneWidget);

    // الضغط على البانر يفتح قسمه
    await tester.tap(find.text('تشكيلة الشيفون'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.category);
    expect(Get.find<CategoryProductsController>().category.id, 'chiffon');
    Get.back();
    await tester.pumpAndSettle();

    // المفضلة مشتركة: القلب في الرئيسية يزيد العداد ويظهر في صفحة المفضلة
    final before = favorites.count;
    final product = home.featuredProducts.first;
    final heart = find.descendant(
      of: find.byType(ProductCard).first,
      matching: find.byType(IconButton),
    );
    await tester.ensureVisible(heart);
    await tester.pumpAndSettle();
    await tester.tap(heart);
    await tester.pump();
    expect(favorites.count, before + 1);
    expect(favorites.isFavorite(product), isTrue);
    home.openFavorites();
    await tester.pumpAndSettle();
    expect(find.text(product.name), findsWidgets);
    Get.back();
    await tester.pumpAndSettle();

    // وصل حديثًا: عرض المزيد لحد ما تخلص، وبعدها رابط كل المنتجات
    expect(home.visibleNewArrivals.length, 2);
    final names = home.newArrivals.map((p) => p.name).toSet();
    expect(names.length, greaterThan(1)); // منتجات مختلفة مش نفس الكارت
    while (home.canLoadMore) {
      await tester.ensureVisible(find.text('عرض المزيد'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('عرض المزيد'));
      await tester.pumpAndSettle();
    }
    expect(home.visibleNewArrivals.length, HomeController.newArrivalsMax);
    expect(find.text('تصفّحي كل المنتجات'), findsOneWidget);

    // زر + يضيف للسلة
    final cart = Get.find<CartController>().count;
    await tester.ensureVisible(find.byTooltip('أضيفي إلى السلة').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('أضيفي إلى السلة').first);
    await tester.pump();
    expect(Get.find<CartController>().count, cart + 1);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // تسوقي حسب المناسبة يفتح القسم المناسب
    await tester.ensureVisible(find.text('الدوام'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الدوام'));
    await tester.pumpAndSettle();
    expect(Get.find<CategoryProductsController>().category.id, 'foal');
    Get.back();
    await tester.pumpAndSettle();

    // الإشعارات: الجرس يفتح صفحة الإشعارات
    expect(home.notifications.unreadCount, greaterThan(0));
    home.openNotifications();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.notifications);
    Get.back();
    await tester.pumpAndSettle();

    // عدد المفضلة في صفحة حسابي يتحدّث
    shell.changeTab(4);
    await tester.pumpAndSettle();
    expect(find.text('${favorites.count}'), findsWidgets);
  });

  testWidgets('search: suggestions, Arabic matching, recent and sort', (
    tester,
  ) async {
    await _useScreen(tester, const Size(412, 915));
    await _startApp(tester);
    Get.offAllNamed(AppRoutes.main);
    await tester.pumpAndSettle();

    // شريط البحث في الرئيسية يفتح الصفحة والكيبورد جاهز
    await tester.tap(find.text('ابحثي عن توب، لون، أو خامة…'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.search);
    final c = Get.find<ProductSearchController>();
    expect(c.focusNode.hasFocus, isTrue);
    expect(c.results.length, Products.all.length);

    // اقتراح → نتائج وكلها حرير
    await tester.tap(find.text('حرير'));
    await tester.pumpAndSettle();
    expect(c.results, isNotEmpty);
    expect(c.results.every((p) => p.kind.contains('حرير')), isTrue);
    expect(find.text('النتائج (${c.results.length})'), findsOneWidget);

    // "مطرز" بدون شدة تلاقي "مطرّز"، و"اصيله" تلاقي "أصيلة"
    await tester.enterText(find.byType(TextField), 'مطرز');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(c.results, isNotEmpty);
    expect(Products.search('اصيله'), isNotEmpty);

    // ترتيب بالسعر
    await tester.tap(find.text('السعر: الأقل'));
    await tester.pumpAndSettle();
    final prices = c.results.map((p) => p.price).toList();
    expect(prices, [...prices]..sort());

    // مسح → رجعت الاقتراحات مع آخر بحث
    await tester.tap(find.byTooltip('مسح'));
    await tester.pumpAndSettle();
    expect(find.text('عمليات البحث الأخيرة'), findsOneWidget);
    expect(c.recent.first, 'حرير');
    Get.back();
    await tester.pumpAndSettle();
    expect(Get.isRegistered<ProductSearchController>(), isFalse);
  });

  testWidgets('account: profile, active order and addresses', (tester) async {
    await _useScreen(tester, const Size(412, 915));
    await _startApp(tester);
    Get.offAllNamed(AppRoutes.main);
    await tester.pumpAndSettle();
    final shell = Get.find<MainShellController>();
    final addresses = Get.find<AddressesController>();
    shell.changeTab(4);
    await tester.pumpAndSettle();

    // بطاقة الحساب + كارت الطلب الحالي + العنوان الافتراضي + الإصدار
    expect(find.text('صلاح الدين حسن مهدي'), findsOneWidget);
    expect(find.text('طلب #TB-20481 · قيد التجهيز'), findsOneWidget);
    expect(find.text('الرياض، الخرطوم'), findsOneWidget);
    expect(find.textContaining('الإصدار'), findsOneWidget);

    // تعديل الاسم ينعكس في حسابي مباشرة
    await tester.tap(find.byTooltip('تعديل الملف الشخصي'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'مريم أحمد');
    await tester.tap(find.text('حفظ التغييرات'));
    await tester.pumpAndSettle();
    expect(find.text('مريم أحمد'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // كارت الطلب الحالي يفتح التتبع
    await tester.tap(find.text('تتبعي'));
    await _pumpFrames(tester);
    expect(Get.currentRoute, AppRoutes.trackOrder);
    Get.back();
    await _pumpFrames(tester);
    await tester.pumpAndSettle();

    // صفحة العناوين: عنوانين، والمنزل هو الافتراضي
    await tester.tap(find.text('عناويني'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.locations);
    expect(find.text('الافتراضي'), findsOneWidget);
    await tester.tap(find.text('تعيين كافتراضي'));
    await tester.pumpAndSettle();
    expect(addresses.defaultAddress!.label, AddressLabel.work);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // إضافة عنوان: التحقق يمنع الحفظ ببيانات ناقصة أو رقم غلط
    await tester.tap(find.text('إضافة عنوان جديد'));
    await tester.pumpAndSettle();
    expect(find.text('عنوان جديد'), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), '12345');
    await tester.tap(find.text('حفظ العنوان'));
    await tester.pumpAndSettle();
    expect(find.text('رقم غير صحيح، مثال: 912345678'), findsOneWidget);
    expect(find.text('اكتبي المدينة أو الحي'), findsOneWidget);
    expect(addresses.count, 2);

    await tester.tap(find.text('أخرى'));
    await tester.enterText(fields.at(1), '0912345678');
    await tester.enterText(fields.at(2), 'ود مدني');
    await tester.enterText(fields.at(3), 'حي الدرجة، منزل 7');
    await tester.ensureVisible(find.text('اجعليه العنوان الافتراضي'));
    await tester.tap(find.text('اجعليه العنوان الافتراضي'));
    await tester.pump();
    await tester.tap(find.text('حفظ العنوان'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.locations);
    expect(addresses.count, 3);
    expect(addresses.defaultAddress!.area, 'ود مدني');
    expect(addresses.defaultAddress!.label, AddressLabel.other);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // تعديل العنوان الجديد
    final newCard = addresses.defaultAddress!;
    addresses.openEdit(newCard);
    await tester.pumpAndSettle();
    expect(find.text('تعديل العنوان'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(2), 'مدني');
    await tester.tap(find.text('حفظ التعديلات'));
    await tester.pumpAndSettle();
    expect(addresses.byId(newCard.id)!.area, 'مدني');
    expect(addresses.count, 3);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // حذف الافتراضي: يتأكد أولًا وبعدين الافتراضي ينتقل لعنوان تاني
    addresses.confirmDelete(addresses.defaultAddress!);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('حذف')),
    );
    await tester.pumpAndSettle();
    expect(addresses.count, 2);
    expect(addresses.defaultAddress, isNotNull);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // الرجوع لحسابي: عدد العناوين اتحدّث
    Get.back();
    await tester.pumpAndSettle();
    expect(find.text('2'), findsWidgets);
  });

  testWidgets('cart: quantities, free delivery, coupon, undo and checkout', (
    tester,
  ) async {
    await _useScreen(tester, const Size(412, 915));
    await _startApp(tester);
    Get.offAllNamed(AppRoutes.main);
    await tester.pumpAndSettle();
    final cart = Get.find<CartController>();
    final shell = Get.find<MainShellController>();
    final orders = Get.find<MyOrderController>();
    shell.changeTab(MainShellController.cartTab);
    await tester.pumpAndSettle();

    // سلة فيها منتجين، تحت حد التوصيل المجاني (السلة بتبدأ فاضية في
    // أول تشغيل، فبنضيفهم)
    expect(cart.isEmpty, isTrue);
    for (final id in ['chiffon-5', 'accessories-2']) {
      cart.add(CartItem.fromProduct(Products.byId(id)!), notify: false);
    }
    await tester.pumpAndSettle();
    expect(cart.count, 2);
    expect(find.text('منتجان'), findsOneWidget);
    expect(cart.hasFreeDelivery, isFalse);
    expect(
      find.textContaining('وتحصلي على توصيل مجاني', findRichText: true),
      findsOneWidget,
    );
    expect(cart.total, cart.subtotal + CartController.deliveryFee);

    // زيادة الكمية تعدّي الحد → التوصيل مجاني
    await tester.tap(find.byTooltip('زيادة الكمية').first);
    await tester.pumpAndSettle();
    expect(cart.count, 3);
    expect(cart.hasFreeDelivery, isTrue);
    expect(find.text('طلبك مؤهل للتوصيل المجاني'), findsOneWidget);
    expect(find.text('مجاني'), findsOneWidget);
    await tester.tap(find.byTooltip('إنقاص الكمية').first);
    await tester.pumpAndSettle();
    expect(cart.count, 2);

    // كود خصم غلط ثم صحيح (بأحرف صغيرة)
    await tester.enterText(find.byType(TextField), 'WRONG');
    await tester.tap(find.text('تطبيق'));
    await tester.pumpAndSettle();
    expect(find.text('الكود غير صحيح أو منتهي'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'toubna10');
    await tester.tap(find.text('تطبيق'));
    await tester.pumpAndSettle();
    expect(cart.couponCode.value, 'TOUBNA10');
    expect(cart.discount, cart.subtotal ~/ 10);
    expect(
      cart.total,
      cart.subtotal - cart.discount + CartController.deliveryFee,
    );
    expect(find.text('الخصم (10٪)'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // حذف بزر السلة ثم تراجع
    final first = cart.items.first;
    await tester.tap(find.byTooltip('حذف من السلة').first);
    await tester.pumpAndSettle();
    expect(cart.items.any((i) => i.id == first.id), isFalse);
    await tester.tap(find.text('تراجع'));
    await tester.pumpAndSettle();
    expect(cart.items.first.id, first.id);

    // حذف بالسحب
    // (الـ snackbar كمان فيه Dismissible، فنحدد بتاع كارت السلة)
    await tester.drag(
      find.descendant(
        of: find.byType(CartItemCard).last,
        matching: find.byType(Dismissible),
      ),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    expect(cart.items.length, 1);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // إتمام الطلب: الشيت يعرض العنوان الافتراضي، والتأكيد ينشئ طلب جديد
    final expectedTotal = cart.total;
    final ordersBefore = orders.currentOrders.length;
    await tester.tap(find.text('إتمام الطلب'));
    await tester.pumpAndSettle();
    expect(find.text('التوصيل إلى: المنزل'), findsOneWidget);
    await tester.tap(find.text('تأكيد الطلب').last);
    await _pumpFrames(tester);
    expect(Get.currentRoute, AppRoutes.trackOrder);
    expect(orders.currentOrders.length, ordersBefore + 1);
    final placed = orders.currentOrders.first;
    expect(placed.status, OrderStatus.placed);
    expect(placed.total, expectedTotal);
    expect(cart.isEmpty, isTrue);
    expect(cart.couponCode.value, isNull);
    expect(shell.currentIndex.value, MainShellController.ordersTab);
    await tester.pump(const Duration(seconds: 3));
    Get.back();
    await _pumpFrames(tester);
    await tester.pumpAndSettle();

    // السلة الفاضية: "ابدئي التسوق" يفتح الأقسام
    shell.changeTab(MainShellController.cartTab);
    await tester.pumpAndSettle();
    expect(find.text('سلتك فاضية'), findsOneWidget);
    expect(find.text('ممكن يعجبك'), findsOneWidget);
    await tester.tap(find.text('ابدئي التسوق'));
    await tester.pumpAndSettle();
    expect(shell.currentIndex.value, 1);

    // بدون عنوان: الشيت ينبّه وزر التأكيد ما بيشتغل
    Get.find<AddressesController>().addresses.clear();
    cart.addProduct(Products.all.first);
    await tester.pump(const Duration(seconds: 5));
    shell.changeTab(MainShellController.cartTab);
    await tester.pumpAndSettle();
    await tester.tap(find.text('إتمام الطلب'));
    await tester.pumpAndSettle();
    expect(find.text('مافي عنوان توصيل'), findsOneWidget);
    await tester.tap(find.text('تأكيد الطلب').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(cart.isEmpty, isFalse);
    expect(orders.currentOrders.length, ordersBefore + 1);
  });

  testWidgets('orders: track, cancel, courier phone and reorder', (
    tester,
  ) async {
    await _useScreen(tester, const Size(412, 915));
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
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
    await _startApp(tester);
    Get.offAllNamed(AppRoutes.main);
    await tester.pumpAndSettle();
    final shell = Get.find<MainShellController>();
    final orders = Get.find<MyOrderController>();
    shell.changeTab(3);
    await tester.pumpAndSettle();

    // الكارت: الحالة + التقدّم + الموعد المتوقع
    expect(find.text('طلب #TB-20481'), findsOneWidget);
    expect(find.text('قيد التجهيز'), findsWidgets);
    expect(
      find.textContaining('الخميس 31 أكتوبر', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('117,300 ج.س'), findsOneWidget);

    // تتبع الطلب الأول
    await tester.tap(find.text('تتبع الطلب').first);
    await _pumpFrames(tester);
    expect(Get.currentRoute, AppRoutes.trackOrder);
    final track = Get.find<TrackOrderController>();
    expect(track.order.value.number, '#TB-20481');
    expect(track.timeline.map((e) => e.state), [
      TimelineState.done,
      TimelineState.current,
      TimelineState.upcoming,
      TimelineState.upcoming,
    ]);
    expect(find.text('المرحلة 2 من 4'), findsOneWidget);

    // الإلغاء: تأكيد ثم ينتقل للطلبات السابقة
    await tester.tap(find.text('إلغاء الطلب'));
    await _pumpFrames(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.text('إلغاء الطلب'),
          )
          .last,
    );
    await _pumpFrames(tester);
    expect(track.order.value.status, OrderStatus.cancelled);
    expect(find.text('تفاصيل الطلب'), findsOneWidget);
    expect(track.timeline.last.state, TimelineState.cancelled);
    expect(orders.currentOrders.length, 1);
    expect(orders.pastOrders.first.number, '#TB-20481');
    await tester.pump(const Duration(seconds: 3));
    Get.back();
    await tester.pumpAndSettle();

    // الطلب اللي في الطريق: بيانات المندوب ونسخ رقمه
    orders.openTracking(orders.currentOrders.first);
    await _pumpFrames(tester);
    expect(find.text('عثمان الطيب'), findsOneWidget);
    expect(find.text('إلغاء الطلب'), findsNothing); // ما ينفع يتلغي بعد الخروج
    await tester.tap(find.byTooltip('نسخ رقم المندوب'));
    await tester.pump();
    expect(copied, '+249 91 234 5678');
    await tester.pump(const Duration(seconds: 3));
    Get.back();
    await tester.pumpAndSettle();

    // السابقة: الملغي ظاهر أول، وإعادة الطلب تزيد السلة
    orders.selectTab(1);
    await tester.pumpAndSettle();
    expect(find.text('طلب #TB-20481'), findsOneWidget);
    expect(find.text('ملغي'), findsWidgets);
    final before = Get.find<CartController>().count;
    await tester.tap(find.text('إعادة الطلب').first);
    await tester.pump();
    expect(Get.find<CartController>().count, before + 2);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // لو مافي طلبات حالية تظهر رسالة فاضية
    orders.currentOrders.clear();
    orders.selectTab(0);
    await tester.pumpAndSettle();
    expect(find.text('مافي طلبات حالية'), findsOneWidget);
  });

  test('order totals add delivery and match the old list', () {
    final totals = [
      for (final o in [...MockOrders.current, ...MockOrders.past]) o.totalText,
    ];
    expect(totals, [
      '117,300 ج.س',
      '113,000 ج.س',
      '101,000 ج.س',
      '130,000 ج.س',
      '45,000 ج.س',
    ]);
  });

  test('formatPrice groups thousands', () {
    expect(formatPrice(8000), '8,000 ج.س');
    expect(formatPrice(85000), '85,000 ج.س');
    expect(formatPrice(117300), '117,300 ج.س');
    expect(formatPrice(1250000), '1,250,000 ج.س');
  });
}

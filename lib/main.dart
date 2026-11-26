import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:toubna/core/i18n/app_translations.dart';
import 'package:toubna/core/i18n/locale_controller.dart';
import 'package:toubna/core/routes/app_pages.dart';
import 'package:toubna/core/services/app_storage.dart';
import 'package:toubna/core/services/connectivity_service.dart';
import 'package:toubna/core/widgets/error_state_view.dart';
import 'package:toubna/core/services/favorites_controller.dart';
import 'package:toubna/core/services/user_controller.dart';
import 'package:toubna/features/addresses/presentation/controllers/addresses_controller.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';
import 'package:toubna/features/notifications/notifications_controller.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/theme/app_theme.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // شاشة النظام تفضل ظاهرة لحد ما شاشة البداية في فلاتر تجهز (SplashController)
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // اللغة المحفوظة (لو اتختارت قبل كده) قبل أول إطار، عشان ما يحصل وميض
  final saved = await AppStorage.language();
  runApp(MyApp(locale: saved == 'en' ? LocaleController.english : null));
}

class MyApp extends StatelessWidget {
  /// اللغة عند التشغيل (العربية لو null).
  final Locale? locale;

  const MyApp({super.key, this.locale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'توبنا'.tr,
      translations: AppTranslations(),
      locale: locale ?? LocaleController.arabic,
      fallbackLocale: LocaleController.arabic,
      supportedLocales: LocaleController.supported,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      // خدمات تعيش طول عمر التطبيق
      initialBinding: BindingsBuilder(() {
        Get.put(
          LocaleController(locale ?? LocaleController.arabic),
          permanent: true,
        );
        Get.put(ConnectivityService(), permanent: true);
        Get.put(UserController(), permanent: true);
        Get.put(NotificationsController(), permanent: true);
        Get.put(FavoritesController(), permanent: true);
        Get.put(AddressesController(), permanent: true);
        Get.put(CartController(), permanent: true);
      }),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
      // نحدّ تكبير الخط عشان التصميم ما يتكسر، مع احترام إعدادات الإتاحة
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.2,
            ),
          ),
          child: _AppFrame(child: child!),
        );
      },
    );
  }
}

/// إطار التطبيق: شريط "مافي إنترنت" فوق كل الشاشات.
class _AppFrame extends StatelessWidget {
  final Widget child;

  const _AppFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ConnectivityService>()) return child;
    final connectivity = Get.find<ConnectivityService>();
    return Obx(() {
      final offline = !connectivity.isOnline.value;
      final reconnected = connectivity.justReconnected.value;
      final banner = offline || reconnected;
      return Column(
        children: [
          ConnectivityBanner(offline: offline, reconnected: reconnected),
          Expanded(
            // الشريط واخد مكان شريط الحالة، فالصفحة تحته ما تحتاج مسافة فوق
            child: banner
                ? MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: child,
                  )
                : child,
          ),
        ],
      );
    });
  }
}

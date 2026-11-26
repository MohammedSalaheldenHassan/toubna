import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/features/account/presentation/controllers/account_controller.dart';
import 'package:toubna/features/account/presentation/controllers/edit_profile_controller.dart';
import 'package:toubna/features/account/presentation/pages/contact_us.dart';
import 'package:toubna/features/account/presentation/pages/edit_profile_screen.dart';
import 'package:toubna/features/account/presentation/pages/fav_screen.dart';
import 'package:toubna/features/account/presentation/pages/terms_and_privacy_policy.dart';
import 'package:toubna/features/addresses/presentation/controllers/address_form_controller.dart';
import 'package:toubna/features/addresses/presentation/pages/address_form_screen.dart';
import 'package:toubna/features/addresses/presentation/pages/locations_screen.dart';
import 'package:toubna/features/auth/login/presentation/controllers/login_controller.dart';
import 'package:toubna/features/auth/login/presentation/pages/login_screen.dart';
import 'package:toubna/features/auth/verify_phone/verify_phone_controller.dart';
import 'package:toubna/features/auth/verify_phone/verify_phone_screen.dart';
import 'package:toubna/features/auth/register/presentation/controllers/register_controller.dart';
import 'package:toubna/features/auth/register/presentation/pages/register_screen.dart';
import 'package:toubna/features/categories/presentation/controllers/category_products_controller.dart';
import 'package:toubna/features/categories/presentation/pages/category_products_screen.dart';
import 'package:toubna/features/detail/presentation/controllers/product_controller.dart';
import 'package:toubna/features/detail/presentation/pages/item_detail.dart';
import 'package:toubna/features/home/presentation/controllers/home_controller.dart';
import 'package:toubna/features/my_order/presentation/controllers/my_order_controller.dart';
import 'package:toubna/features/my_order/presentation/controllers/track_order_controller.dart';
import 'package:toubna/features/my_order/presentation/pages/track_order_screen.dart';
import 'package:toubna/features/notifications/notifications_screen.dart';
import 'package:toubna/features/onboarding/onboarding_controller.dart';
import 'package:toubna/features/onboarding/onboarding_screen.dart';
import 'package:toubna/features/routes/main_shell_controller.dart';
import 'package:toubna/features/routes/routes.dart';
import 'package:toubna/features/search/presentation/controllers/product_search_controller.dart';
import 'package:toubna/features/search/presentation/pages/search_screen.dart';
import 'package:toubna/features/splash/splash_controller.dart';
import 'package:toubna/features/splash/splash_screen.dart';

/// كل صفحة مع الـ Binding بتاعها: الكنترولر يتسجّل لما الصفحة تفتح
/// ويتحذف تلقائيًا لما تتقفل.
abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder.put(() => SplashController()),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder.put(() => OnboardingController()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder.put(() => LoginController()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder.put(() => RegisterController()),
    ),
    GetPage(
      name: AppRoutes.verifyPhone,
      page: () => const VerifyPhoneScreen(),
      binding: BindingsBuilder.put(() => VerifyPhoneController()),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainShell(),
      // تبويبات الشريط السفلي كلها تعيش طول ما الـ Shell مفتوح
      binding: BindingsBuilder(() {
        Get.put(MainShellController());
        Get.put(HomeController());
        Get.put(MyOrderController());
        Get.put(AccountController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
    ),
    GetPage(
      name: AppRoutes.product,
      page: () => const ProductScreen(),
      binding: BindingsBuilder.put(() => ProductController()),
    ),
    GetPage(
      name: AppRoutes.trackOrder,
      page: () => const TrackOrderScreen(),
      binding: BindingsBuilder.put(() => TrackOrderController()),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      binding: BindingsBuilder.put(() => ProductSearchController()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.category,
      page: () => const CategoryProductsScreen(),
      binding: BindingsBuilder.put(() => CategoryProductsController()),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: BindingsBuilder.put(() => EditProfileController()),
    ),
    GetPage(name: AppRoutes.locations, page: () => const LocationsScreen()),
    GetPage(
      name: AppRoutes.addressForm,
      page: () => const AddressFormScreen(),
      binding: BindingsBuilder.put(() => AddressFormController()),
    ),
    GetPage(name: AppRoutes.favorites, page: () => const FavScreen()),
    GetPage(name: AppRoutes.contactUs, page: () => const ContactUs()),
    GetPage(name: AppRoutes.terms, page: () => const TermsAndPrivacyPolicy()),
  ];
}

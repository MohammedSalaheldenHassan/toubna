# توبنا · Toubna

> متجر إلكتروني للتوب السوداني — تطبيق Flutter بالعربي والإنجليزي.
> كل الشاشات جاهزة وشغالة على بيانات تجريبية، ومستعدة للربط بالـ API.

Toubna is a mobile e-commerce app for the traditional Sudanese **toub**. It is
built with Flutter and GetX, ships in **Arabic (RTL) and English (LTR)**, and
currently runs on local demo data with clearly marked integration points for
the backend.

---

## Features

| Area | What's in it |
|---|---|
| **Onboarding** | 3 animated pages, language toggle, shown once |
| **Auth** | Login, register with field validation, **phone verification by SMS code**, forgot password (email → code → new password) |
| **Home** | Auto-rotating promo carousel, categories, best sellers, shop by occasion, new arrivals, pull-to-refresh |
| **Catalog** | Category pages with sort/filter, product page with colour gallery & lengths, Arabic-aware search with suggestions & recent searches |
| **Cart & checkout** | Quantities, swipe-to-delete with undo, coupons, free-delivery progress, checkout sheet → real order |
| **Orders** | Current/past tabs, tracking timeline, courier call/copy, cancel, reorder |
| **Account** | Profile & photo, addresses (add/edit/delete/default), favorites, notifications, language, contact us, terms & privacy, **delete account** |
| **Quality** | Shimmer skeletons, offline banner + error/retry screens, cart & favorites saved on device, responsive from 320 px phones to tablets |

## Tech stack

- **Flutter** 3.44 / Dart 3.12
- **GetX** — state management, routing & bindings, translations
- `shared_preferences` — on-device storage (cart, favorites, settings)
- `connectivity_plus` — online/offline detection
- `cached_network_image` — network images with caching (for API image URLs)
- `url_launcher` — call / WhatsApp / email
- `image_picker` — profile photo
- `flutter_native_splash`, `flutter_launcher_icons`
- Fonts: **IBM Plex Sans Arabic** (body) and **Reem Kufi** (headings)

## Getting started

```bash
flutter pub get
flutter run                 # debug on a device/emulator
flutter test                # 40 widget & unit tests
flutter analyze             # should report: No issues found!
flutter build apk --release # Android
```

After changing the icon or splash assets:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Demo data (until the API is connected)

| What | Value |
|---|---|
| Login | any valid email + any password |
| Phone verification code | `1234` (shown as a hint in debug builds) |
| Coupons | `TOUBNA10` (10%), `ARAS30` (30%) |
| Delete-account password | any password of 6+ characters |

## Project structure

```
lib/
├── main.dart                 # app entry: theme, translations, services, routes, offline banner
├── core/
│   ├── config/               # AppInfo (version, support phone/email)
│   ├── data/                 # catalog (categories/products) & AppImages (all image paths)
│   ├── i18n/                 # AppTranslations (en), LocaleController, plural helper
│   ├── routes/               # AppRoutes (names) & AppPages (pages + bindings)
│   ├── services/             # app-wide: user, favorites, connectivity, storage
│   ├── theme/                # colours & theme
│   ├── utils/                # LoadingState, validators, messages, external links
│   └── widgets/              # shared UI: shimmer, product card, error view, OTP input…
└── features/
    ├── splash/  onboarding/  auth/ (login, register, verify_phone)
    ├── home/  categories/  search/  detail/ (product page)
    ├── cart/  my_order/  addresses/  notifications/  account/
    └── routes/               # MainShell (bottom navigation)
```

Each feature follows `data/` (models) → `presentation/controllers` (GetX) →
`presentation/pages` + `widgets`.

## Architecture notes

- **State:** one GetX controller per screen, created by the route's binding and
  disposed when the route closes. Shared state lives in permanent services
  registered in `initialBinding` (`main.dart`): user, favorites, addresses,
  cart, notifications, connectivity, locale.
- **Loading & errors:** controllers mix in `LoadingState`
  (`core/utils/simulated_loading.dart`). `load()` shows the shimmer skeleton,
  then content — or an `ErrorStateView` (offline / server error) with a retry
  button. Offline screens reload automatically when the connection returns.
- **Persistence:** `AppStorage` wraps `shared_preferences`. The cart (with
  coupon), favorites, notification setting, profile photo, language and
  onboarding flag survive restarts. Deleting the account clears user data.
- **Localization:** the Arabic text **is** the translation key:
  `'السلة'.tr` → "السلة" / "Cart". Values use `trParams` with `@p0` style
  placeholders. To add text, write it in Arabic with `.tr` and add the English
  line in `lib/core/i18n/app_translations.dart`. The test
  *"every Arabic text in the code has an English translation"* fails if one is
  missing. Data (product names, statuses…) is stored as Arabic keys and
  translated at display time, so switching language updates everything live.
- **Images:** every content image path is in `lib/core/data/app_images.dart`.
  `AppImage` accepts asset paths *and* `https://` URLs. See
  [docs/IMAGES.md](docs/IMAGES.md).

## Connecting the backend

All 28 places that need an API call are marked with `// هنا لاحقًا` ("later").
The main ones:

| Feature | Where |
|---|---|
| Login / register / OTP / forgot password | `features/auth/**/controllers` |
| Catalog, category, product, search | `HomeController`, `CategoryProductsController`, `ProductController`, `ProductSearchController` — replace `load()` with `load(() => api.…)` |
| Cart sync & checkout | `CartController` (`placeOrder`) |
| Orders, tracking, cancel | `MyOrderController`, `TrackOrderController` |
| Addresses, profile, photo upload, delete account | `features/account`, `features/addresses` |
| Notifications (FCM) | `NotificationsController` |

Still needed for integration: an HTTP client and repositories, JSON models,
secure token storage (`flutter_secure_storage`), and an SMS provider for OTP.

## Testing

```bash
flutter test
```

- `test/widget_test.dart` — every screen at 320 px, 360 px (+ large text),
  412 px and tablet with no overflow; cart, orders, search, home, account flows.
- `test/i18n_test.dart` — translation coverage, English flow & RTL/LTR,
  English layout at all sizes.
- `test/features_test.dart` — persistence, offline handling, register + phone
  verification, delete account, notifications, every formerly dead button.

Tests load the real app fonts (`test/flutter_test_config.dart`) so overflow
checks match real devices.

## Before release

- [ ] Replace demo product photos — some contain other sellers' branding
      (see [docs/IMAGES.md](docs/IMAGES.md))
- [ ] Real support phone/email in `lib/core/config/app_info.dart`
- [ ] Legal review of the Terms & Privacy text
- [ ] Change `applicationId` (`com.example.toubna`) and set up release signing
- [ ] Build & test on iOS and real devices
- [ ] Analytics & crash reporting

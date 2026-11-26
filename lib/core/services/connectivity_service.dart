import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:toubna/core/utils/app_message.dart';

/// حالة الاتصال بالإنترنت على مستوى التطبيق.
///
/// ملاحظة: الجهاز ممكن يكون متصل بواي فاي بدون إنترنت فعلي — ده بيظهر
/// كخطأ في الطلب نفسه (LoadingState) لما يتربط الـ API.
class ConnectivityService extends GetxService {
  final isOnline = true.obs;

  /// بيظهر لحظة "رجع الاتصال" بعد ما كان مقطوع.
  final justReconnected = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _reconnectedTimer;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  Future<void> _start() async {
    try {
      final connectivity = Connectivity();
      _apply(await connectivity.checkConnectivity());
      _sub = connectivity.onConnectivityChanged.listen(
        _apply,
        onError: (_) {}, // الـ plugin مش متاح (مثلاً في الاختبارات)
      );
    } catch (_) {
      // ما قدرنا نعرف الحالة → نفترض متصل، والطلبات نفسها بتكشف المشكلة
    }
  }

  void _apply(List<ConnectivityResult> results) =>
      setOnline(results.any((r) => r != ConnectivityResult.none));

  /// متاحة للاختبارات وللـ API (لو الطلب فشل بسبب الشبكة).
  void setOnline(bool online) {
    if (online == isOnline.value) return;
    isOnline.value = online;
    _reconnectedTimer?.cancel();
    justReconnected.value = online;
    if (online) {
      _reconnectedTimer = Timer(
        const Duration(seconds: 2),
        () => justReconnected.value = false,
      );
    }
  }

  /// للأزرار اللي محتاجة إنترنت (دخول، تسجيل، إتمام طلب...):
  /// ترجع false وتعرض رسالة لو مافي اتصال.
  bool ensureOnline() {
    if (isOnline.value) return true;
    showAppMessage('مافي اتصال بالإنترنت. اتأكدي من الشبكة وحاولي تاني.'.tr);
    return false;
  }

  @override
  void onClose() {
    _sub?.cancel();
    _reconnectedTimer?.cancel();
    super.onClose();
  }
}

/// بيتنادي من `requireOnline()` عشان ما نكرر Get.find في كل مكان.
bool requireOnline() => Get.isRegistered<ConnectivityService>()
    ? Get.find<ConnectivityService>().ensureOnline()
    : true;

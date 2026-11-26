import 'package:get/get.dart';
import 'package:toubna/core/services/connectivity_service.dart';

/// مدة التحميل التجريبية لحد ما الـ API يجهز.
abstract final class AppConfig {
  static const pageLatency = Duration(milliseconds: 900);
  static const quickLatency = Duration(milliseconds: 500);
}

/// سبب فشل التحميل — كل نوع ليه رسالة وشكل في [ErrorStateView].
enum LoadError { offline, server }

/// الطلب فشل لأن مافي إنترنت (الـ API يرميه لما الاتصال يقع).
class NoConnectionException implements Exception {
  const NoConnectionException();
}

/// حالة تحميل للكنترولر: تحميل → محتوى، أو خطأ مع إعادة محاولة.
/// حاليًا تأخير تجريبي، ولاحقًا يتبدّل بنداء الـ API:
///
/// ```dart
/// await load(() => api.fetchHome());
/// ```
///
/// - لو مافي إنترنت: [error] = offline، والتحميل بيتعاد تلقائيًا أول ما
///   الاتصال يرجع.
/// - لو الطلب رمى أي خطأ تاني: [error] = server.
mixin LoadingState on GetxController {
  final isLoading = true.obs;
  final error = Rxn<LoadError>();

  Future<void> Function()? _lastRequest;
  Duration _lastLatency = AppConfig.pageLatency;
  Worker? _reconnectWorker;

  bool get hasError => error.value != null;

  Future<void> load([
    Future<void> Function()? request,
    Duration latency = AppConfig.pageLatency,
  ]) async {
    _lastRequest = request;
    _lastLatency = latency;
    _watchReconnect();
    isLoading.value = true;
    error.value = null;
    try {
      if (!_online) throw const NoConnectionException();
      await (request?.call() ?? Future.delayed(latency));
      // الاتصال ممكن يقع والطلب شغال
      if (!_online) throw const NoConnectionException();
    } on NoConnectionException {
      if (!isClosed) error.value = LoadError.offline;
    } catch (_) {
      if (!isClosed) error.value = LoadError.server;
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  /// زر "حاولي تاني".
  Future<void> retry() => load(_lastRequest, _lastLatency);

  bool get _online =>
      !Get.isRegistered<ConnectivityService>() ||
      Get.find<ConnectivityService>().isOnline.value;

  void _watchReconnect() {
    if (_reconnectWorker != null || !Get.isRegistered<ConnectivityService>()) {
      return;
    }
    _reconnectWorker = ever<bool>(Get.find<ConnectivityService>().isOnline, (
      online,
    ) {
      if (online && error.value == LoadError.offline && !isClosed) retry();
    });
  }

  @override
  void onClose() {
    _reconnectWorker?.dispose();
    super.onClose();
  }
}

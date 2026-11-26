import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/utils/simulated_loading.dart';

/// شاشة الخطأ: مافي إنترنت أو حصلت مشكلة، مع زر "حاولي تاني".
class ErrorStateView extends StatelessWidget {
  final LoadError error;
  final VoidCallback onRetry;

  /// true = نسخة أصغر داخل جزء من الصفحة.
  final bool compact;

  const ErrorStateView({
    super.key,
    required this.error,
    required this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final offline = error == LoadError.offline;
    final circle = compact ? 72.0 : 96.0;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: compact ? 24 : 48,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circle,
              height: circle,
              decoration: BoxDecoration(
                color: offline
                    ? AppColors.primarySoft
                    : const Color(0xFFFDECEC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                size: circle * 0.45,
                color: offline ? AppColors.primary : AppColors.danger,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              offline ? 'مافي اتصال بالإنترنت'.tr : 'حصلت مشكلة'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 17 : 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              offline
                  ? 'اتأكدي من الواي فاي أو بيانات الموبايل، وهنحمّل تلقائيًا أول ما الاتصال يرجع.'
                        .tr
                  : 'ما قدرنا نحمّل البيانات. حاولي تاني بعد شوية.'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  'حاولي تاني'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شريط أعلى التطبيق كله: "مافي إنترنت" / "رجع الاتصال".
class ConnectivityBanner extends StatelessWidget {
  final bool offline;
  final bool reconnected;

  const ConnectivityBanner({
    super.key,
    required this.offline,
    required this.reconnected,
  });

  @override
  Widget build(BuildContext context) {
    final show = offline || reconnected;
    final top = MediaQuery.paddingOf(context).top;
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: !show
          ? const SizedBox(width: double.infinity)
          : Material(
              color: offline ? AppColors.textDark : const Color(0xFF166534),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, top + 6, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      offline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        offline
                            ? 'أنتِ غير متصلة بالإنترنت'.tr
                            : 'رجع الاتصال'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

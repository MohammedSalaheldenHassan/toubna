import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toubna/core/services/connectivity_service.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/utils/app_message.dart';
import 'package:toubna/core/utils/external_links.dart';
import 'package:toubna/core/utils/simulated_loading.dart';
import 'package:toubna/features/my_order/data/order_models.dart';
import 'package:toubna/features/my_order/presentation/controllers/my_order_controller.dart';

enum TimelineState { done, current, upcoming, cancelled }

class TimelineEntry {
  final String title;
  final String description;
  final String? time;
  final TimelineState state;

  const TimelineEntry(this.title, this.description, this.time, this.state);
}

/// يفتح بـ Get.toNamed(AppRoutes.trackOrder, arguments: order.number)
class TrackOrderController extends GetxController with LoadingState {
  late final MyOrderController _orders = Get.find<MyOrderController>();
  late final Rx<Order> order;

  @override
  void onInit() {
    super.onInit();
    final number = Get.arguments is String ? Get.arguments as String : '';
    order =
        (_orders.findOrder(number) ??
                [..._orders.currentOrders, ..._orders.pastOrders].first)
            .obs;
    // هنا لاحقًا: load(() => api.fetchOrderTracking(number))
    load(null, AppConfig.quickLatency);
  }

  String countText(int count) => _orders.countText(count);

  /// مراحل الطلب مع حالة كل مرحلة ووقتها.
  List<TimelineEntry> get timeline {
    final o = order.value;
    if (o.status == OrderStatus.cancelled) {
      return [
        for (final step in OrderStatus.steps)
          if (o.timeOf(step) != null)
            TimelineEntry(
              step.label,
              step.description,
              o.timeOf(step),
              TimelineState.done,
            ),
        TimelineEntry(
          OrderStatus.cancelled.description,
          'لو دفعتي مبلغ، هيرجع ليك خلال 3 أيام عمل'.tr,
          o.timeOf(OrderStatus.cancelled),
          TimelineState.cancelled,
        ),
      ];
    }
    final reached = o.status.stepIndex;
    return [
      for (final (i, step) in OrderStatus.steps.indexed)
        TimelineEntry(
          step.label,
          step.description,
          o.timeOf(step),
          i < reached || o.status == OrderStatus.delivered
              ? TimelineState.done
              : i == reached
              ? TimelineState.current
              : TimelineState.upcoming,
        ),
    ];
  }

  void copyCourierPhone() {
    final phone = order.value.courierPhone;
    if (phone == null) return;
    Clipboard.setData(ClipboardData(text: phone));
    showAppMessage('تم نسخ رقم المندوب'.tr);
  }

  void callCourier() {
    final phone = order.value.courierPhone;
    if (phone == null) return;
    openExternal(
      Uri(scheme: 'tel', path: phone.replaceAll(' ', '')),
      copyValue: phone,
    );
  }

  void contactUs() => Get.toNamed(AppRoutes.contactUs);

  void reorder() => _orders.reorder(order.value);

  void confirmCancel() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'إلغاء الطلب'.tr,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'متأكدة إنك عايزة تلغي طلب @p0؟'.trParams({'p0': order.value.number}),
          style: const TextStyle(fontSize: 15, color: AppColors.textBody),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'تراجع'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: _cancel,
            child: Text(
              'إلغاء الطلب'.tr,
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cancel() {
    Get.back(); // يقفل الحوار
    if (!requireOnline()) return;
    final cancelled = _orders.cancelOrder(order.value.number);
    if (cancelled != null) order.value = cancelled;
    showAppMessage('تم إلغاء الطلب'.tr);
  }
}

import 'package:get/get.dart';
import 'package:toubna/core/i18n/plural.dart';
import 'package:toubna/core/utils/simulated_loading.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/utils/app_message.dart';
import 'package:toubna/features/cart/presentation/controllers/cart_controller.dart';
import 'package:toubna/features/my_order/data/order_models.dart';

class MyOrderController extends GetxController with LoadingState {
  final selectedTab = 0.obs; // 0 = الحالية ، 1 = السابقة

  final currentOrders = MockOrders.current.toList().obs;
  final pastOrders = MockOrders.past.toList().obs;

  @override
  void onInit() {
    super.onInit();
    load(); // هنا لاحقًا: load(() => api.fetchOrders())
  }

  List<Order> get visibleOrders =>
      selectedTab.value == 0 ? currentOrders : pastOrders;

  void selectTab(int index) => selectedTab.value = index;

  String countText(int count) => itemsText(count);

  Order? findOrder(String number) {
    for (final o in [...currentOrders, ...pastOrders]) {
      if (o.number == number) return o;
    }
    return null;
  }

  void openTracking(Order order) =>
      Get.toNamed(AppRoutes.trackOrder, arguments: order.number);

  void reorder(Order order) {
    Get.find<CartController>().addOrderItems(order.items);
    showAppMessage(
      'تمت إضافة @p0 إلى السلة'.trParams({'p0': countText(order.itemCount)}),
      actionLabel: 'عرض السلة'.tr,
      onAction: Get.find<CartController>().openCart,
    );
  }

  /// مع حذف الحساب.
  void clearAll() {
    currentOrders.clear();
    pastOrders.clear();
  }

  /// طلب جديد من السلة يظهر أول "الحالية".
  void addOrder(Order order) {
    currentOrders.insert(0, order);
    selectedTab.value = 0;
  }

  /// ينقل الطلب من "الحالية" لـ "السابقة" بحالة ملغي ويرجّع النسخة الجديدة.
  Order? cancelOrder(String number) {
    final index = currentOrders.indexWhere((o) => o.number == number);
    if (index == -1) return null;
    // هنا لاحقًا: تنادي الـ API لإلغاء الطلب
    final old = currentOrders.removeAt(index);
    final cancelled = old.copyWith(
      status: OrderStatus.cancelled,
      times: {...old.times, OrderStatus.cancelled: 'الآن'},
    );
    pastOrders.insert(0, cancelled);
    return cancelled;
  }
}

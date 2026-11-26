import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/services/connectivity_service.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/services/app_storage.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/utils/app_message.dart';
import 'package:toubna/features/addresses/presentation/controllers/addresses_controller.dart';
import 'package:toubna/features/cart/data/cart_item.dart';
import 'package:toubna/features/my_order/data/order_models.dart';
import 'package:toubna/features/my_order/presentation/controllers/my_order_controller.dart';
import 'package:toubna/features/routes/main_shell_controller.dart';

/// السلة على مستوى التطبيق (الرئيسية، صفحة المنتج، إعادة الطلب، تبويب السلة).
class CartController extends GetxController {
  static const deliveryFee = 3000;
  static const freeDeliveryThreshold = 100000;

  /// أكواد الخصم المتاحة ونسبتها.
  static const _coupons = {'TOUBNA10': 10, 'ARAS30': 30};

  // بتتحفظ على الجهاز — هنا لاحقًا: تتزامن مع الـ API
  final items = <CartItem>[].obs;

  final couponCode = RxnString();
  final couponError = RxnString();
  final couponController = TextEditingController();

  /// بيكتمل بعد قراءة السلة المحفوظة.
  late final Future<void> ready = _restore();

  @override
  void onInit() {
    super.onInit();
    ready;
  }

  Future<void> _restore() async {
    final saved = await AppStorage.readJson(AppStorage.cartKey);
    if (saved is Map) {
      items.assignAll([
        for (final json in (saved['items'] as List? ?? const []))
          ?CartItem.fromJson(json),
      ]);
      final code = saved['coupon'];
      if (code is String && _coupons.containsKey(code)) couponCode.value = code;
    }
    // من هنا وطالع: أي تغيير في السلة أو الكود يتحفظ
    everAll([items, couponCode], (_) => _save());
  }

  Future<void> _save() => AppStorage.writeJson(AppStorage.cartKey, {
    'items': [for (final i in items) i.toJson()],
    'coupon': couponCode.value,
  });

  // ---------- الحسابات ----------
  int get count => items.fold(0, (sum, i) => sum + i.qty);
  bool get isEmpty => items.isEmpty;
  int get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);
  int get discountPercent => _coupons[couponCode.value] ?? 0;
  int get discount => subtotal * discountPercent ~/ 100;
  bool get hasFreeDelivery => subtotal >= freeDeliveryThreshold;
  int get delivery => isEmpty || hasFreeDelivery ? 0 : deliveryFee;
  int get total => subtotal - discount + delivery;
  int get remainingForFreeDelivery =>
      (freeDeliveryThreshold - subtotal).clamp(0, freeDeliveryThreshold);
  double get freeDeliveryProgress =>
      (subtotal / freeDeliveryThreshold).clamp(0.0, 1.0);

  // ---------- الإضافة والتعديل ----------
  /// يضيف للسلة، ولو نفس السطر موجود يزيد الكمية (بحد المخزون).
  void add(CartItem item, {bool notify = true}) {
    final i = items.indexWhere((x) => x.id == item.id);
    if (i == -1) {
      items.add(item);
    } else {
      final old = items[i];
      items[i] = old.copyWith(qty: (old.qty + item.qty).clamp(1, old.maxQty));
    }
    if (notify) {
      showAppMessage(
        'تمت إضافة "@p0" إلى السلة'.trParams({'p0': item.name}),
        actionLabel: 'عرض السلة'.tr,
        onAction: openCart,
      );
    }
  }

  void addProduct(Product p) => add(CartItem.fromProduct(p));

  void addOrderItems(List<OrderItem> orderItems) {
    for (final i in orderItems) {
      add(CartItem.fromOrderItem(i), notify: false);
    }
  }

  void increment(CartItem item) => _setQty(item, item.qty + 1);

  void decrement(CartItem item) => _setQty(item, item.qty - 1);

  void _setQty(CartItem item, int qty) {
    final i = items.indexWhere((x) => x.id == item.id);
    if (i == -1 || qty < 1 || qty > item.maxQty) return;
    items[i] = item.copyWith(qty: qty);
  }

  /// يحذف السطر مع إمكانية التراجع.
  void remove(CartItem item) {
    final i = items.indexWhere((x) => x.id == item.id);
    if (i == -1) return;
    items.removeAt(i);
    showAppMessage(
      'تم حذف "@p0"'.trParams({'p0': item.name}),
      actionLabel: 'تراجع'.tr,
      onAction: () => items.insert(i.clamp(0, items.length), item),
    );
  }

  void confirmClear() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تفريغ السلة'.tr,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'متأكدة إنك عايزة تشيلي كل المنتجات من السلة؟'.tr,
          style: TextStyle(fontSize: 15, color: AppColors.textBody),
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
            onPressed: () {
              Get.back();
              clear();
            },
            child: Text(
              'تفريغ'.tr,
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

  void clear() {
    items.clear();
    removeCoupon();
  }

  // ---------- كود الخصم ----------
  void applyCoupon() {
    final code = couponController.text.trim().toUpperCase();
    if (code.isEmpty) {
      couponError.value = 'اكتبي كود الخصم'.tr;
    } else if (!_coupons.containsKey(code)) {
      couponError.value = 'الكود غير صحيح أو منتهي'.tr;
    } else {
      couponCode.value = code;
      couponError.value = null;
      couponController.clear();
      showAppMessage('تم تطبيق خصم @p0٪'.trParams({'p0': '${_coupons[code]}'}));
    }
  }

  void removeCoupon() {
    couponCode.value = null;
    couponError.value = null;
  }

  // ---------- إتمام الطلب ----------
  /// ينشئ طلب جديد بالعنوان الافتراضي ويفضّي السلة ويفتح التتبع.
  Order? placeOrder() {
    final address = Get.find<AddressesController>().defaultAddress;
    if (isEmpty || address == null) return null;
    final orders = Get.find<MyOrderController>();
    // هنا لاحقًا: ترسل الطلب للـ API وترجع رقمه
    final order = Order(
      number:
          '#TB-${20482 + orders.currentOrders.length + orders.pastOrders.length}',
      date: 'الآن',
      status: OrderStatus.placed,
      items: [for (final i in items) i.toOrderItem()],
      deliveryFee: delivery,
      discount: discount,
      address: address.fullText,
      eta: 'خلال 2-3 أيام',
      times: {OrderStatus.placed: 'الآن'},
    );
    orders.addOrder(order);
    clear();
    return order;
  }

  /// من شيت التأكيد: ينشئ الطلب ويفتح صفحة تتبعه.
  void confirmCheckout() {
    if (!requireOnline()) return;
    final order = placeOrder();
    if (order == null) return;
    Get.back(); // يقفل الشيت
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().changeTab(MainShellController.ordersTab);
    }
    Get.find<MyOrderController>().openTracking(order);
    showAppMessage(
      'تم استلام طلبك @p0، هنبدأ نجهّزه'.trParams({'p0': order.number}),
    );
  }

  /// يرجع للـ Shell ويفتح تبويب السلة (من أي صفحة فوقه).
  void openCart() {
    Get.until((route) => route.settings.name == AppRoutes.main);
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().changeTab(MainShellController.cartTab);
    }
  }

  @override
  void onClose() {
    couponController.dispose();
    super.onClose();
  }
}

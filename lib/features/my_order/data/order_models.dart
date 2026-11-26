import 'package:get/get.dart';
import 'package:toubna/core/data/app_images.dart';
import 'package:toubna/core/data/catalog.dart';

/// مراحل الطلب بالترتيب، والإلغاء حالة منفصلة.
enum OrderStatus {
  placed('تم استلام الطلب', 'استلمنا طلبك وبنراجعه'),
  preparing('قيد التجهيز', 'بنجهّز توبك ونغلّفه بعناية'),
  outForDelivery('خرج للتوصيل', 'المندوب في الطريق ليك'),
  delivered('تم التوصيل', 'وصل طلبك، نتمنى يعجبك'),
  cancelled('ملغي', 'تم إلغاء الطلب');

  const OrderStatus(this.labelKey, this.descriptionKey);
  final String labelKey;
  final String descriptionKey;

  String get label => labelKey.tr;
  String get description => descriptionKey.tr;

  /// مراحل الشريط الزمني (من غير الإلغاء).
  static const steps = [placed, preparing, outForDelivery, delivered];

  int get stepIndex => steps.indexOf(this);
  bool get isActive => this != delivered && this != cancelled;
  bool get canCancel => this == placed || this == preparing;
}

class OrderItem {
  final String nameKey;
  final String kindKey;
  final String image;
  final int qty;
  final int price;

  const OrderItem({
    required String name,
    required String kind,
    required this.image,
    required this.price,
    this.qty = 1,
  }) : nameKey = name,
       kindKey = kind;

  String get name => nameKey.tr;
  String get kind => kindKey.tr;

  int get lineTotal => price * qty;
}

class Order {
  final String number;
  final String dateKey;
  final OrderStatus status;
  final List<OrderItem> items;
  final int deliveryFee;
  final int discount;
  final String addressKey;
  final String paymentMethodKey;

  /// وقت كل مرحلة وصلها الطلب.
  final Map<OrderStatus, String> times;
  final String? etaKey;
  final String? courierName;
  final String? courierPhone;

  const Order({
    required this.number,
    required String date,
    required this.status,
    required this.items,
    required String address,
    required this.times,
    this.deliveryFee = 3000,
    this.discount = 0,
    String paymentMethod = 'الدفع عند الاستلام',
    String? eta,
    this.courierName,
    this.courierPhone,
  }) : dateKey = date,
       addressKey = address,
       paymentMethodKey = paymentMethod,
       etaKey = eta;

  String get date => dateKey.tr;
  String get address => addressKey.tr;
  String get paymentMethod => paymentMethodKey.tr;
  String? get eta => etaKey?.tr;

  /// وقت المرحلة (مترجم)، أو null لو الطلب ما وصلها.
  String? timeOf(OrderStatus step) => times[step]?.tr;

  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);
  int get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);
  int get total => subtotal + deliveryFee - discount;
  String get totalText => formatPrice(total);
  List<String> get images => [for (final i in items) i.image];

  Order copyWith({OrderStatus? status, Map<OrderStatus, String>? times}) {
    return Order(
      number: number,
      date: dateKey,
      status: status ?? this.status,
      items: items,
      address: addressKey,
      times: times ?? this.times,
      deliveryFee: deliveryFee,
      discount: discount,
      paymentMethod: paymentMethodKey,
      eta: status == OrderStatus.cancelled ? null : etaKey,
      courierName: courierName,
      courierPhone: courierPhone,
    );
  }
}

/// بيانات تجريبية — لاحقًا تجي من الـ API.
abstract final class MockOrders {
  static const _address = 'الخرطوم، الرياض — شارع المشتل، منزل 14';

  static const current = [
    Order(
      number: '#TB-20481',
      date: 'اليوم، 7:45 م',
      status: OrderStatus.preparing,
      deliveryFee: 2300,
      address: _address,
      eta: 'الخميس 31 أكتوبر',
      times: {
        OrderStatus.placed: 'اليوم، 7:45 م',
        OrderStatus.preparing: 'اليوم، 8:10 م',
      },
      items: [
        OrderItem(
          name: 'وردة النيل',
          kind: 'سويسري مطرّز',
          image: AppImages.categorySwiss,
          price: 85000,
        ),
        OrderItem(
          name: 'نسمة كسلا',
          kind: 'فوال سادة',
          image: AppImages.categoryFoal,
          price: 30000,
        ),
      ],
    ),
    Order(
      number: '#TB-20455',
      date: 'أمس، 2:10 م',
      status: OrderStatus.outForDelivery,
      address: _address,
      eta: 'اليوم قبل 6:00 م',
      courierName: 'عثمان الطيب',
      courierPhone: '+249 91 234 5678',
      times: {
        OrderStatus.placed: 'أمس، 2:10 م',
        OrderStatus.preparing: 'أمس، 4:30 م',
        OrderStatus.outForDelivery: 'اليوم، 10:15 ص',
      },
      items: [
        OrderItem(
          name: 'نجمة الليل',
          kind: 'مشغول بخيوط ذهبية',
          image: AppImages.categoryMashghool,
          price: 110000,
        ),
      ],
    ),
  ];

  static const past = [
    Order(
      number: '#TB-20377',
      date: '19 أكتوبر 2026',
      status: OrderStatus.delivered,
      address: _address,
      times: {
        OrderStatus.placed: '19 أكتوبر، 11:00 ص',
        OrderStatus.preparing: '19 أكتوبر، 1:20 م',
        OrderStatus.outForDelivery: '20 أكتوبر، 9:40 ص',
        OrderStatus.delivered: '20 أكتوبر، 2:05 م',
      },
      items: [
        OrderItem(
          name: 'ليالي سنار',
          kind: 'حرير بنقوش',
          image: AppImages.categorySilk,
          price: 98000,
        ),
      ],
    ),
    Order(
      number: '#TB-20214',
      date: '2 أكتوبر 2026',
      status: OrderStatus.delivered,
      address: _address,
      times: {
        OrderStatus.placed: '2 أكتوبر، 6:30 م',
        OrderStatus.preparing: '3 أكتوبر، 10:00 ص',
        OrderStatus.outForDelivery: '3 أكتوبر، 3:15 م',
        OrderStatus.delivered: '3 أكتوبر، 7:40 م',
      },
      items: [
        OrderItem(
          name: 'زهرة الخرطوم',
          kind: 'قرمصيص مطرّز',
          image: AppImages.categoryGarmasis,
          price: 95000,
        ),
        OrderItem(
          name: 'قمر توتي',
          kind: 'مشغول سادة',
          image: AppImages.categoryMashghool,
          price: 32000,
        ),
      ],
    ),
    Order(
      number: '#TB-20102',
      date: '14 سبتمبر 2026',
      status: OrderStatus.cancelled,
      address: _address,
      times: {
        OrderStatus.placed: '14 سبتمبر، 9:20 ص',
        OrderStatus.cancelled: '14 سبتمبر، 9:45 ص',
      },
      items: [
        OrderItem(
          name: 'نسيم البحر',
          kind: 'فوال بنقوش',
          image: AppImages.categoryFoal,
          price: 42000,
        ),
      ],
    ),
  ];
}

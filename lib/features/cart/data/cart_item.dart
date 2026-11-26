import 'package:get/get.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/features/my_order/data/order_models.dart';

class CartItem {
  /// نفس المنتج بلون/طول مختلف = سطر منفصل في السلة.
  final String id;

  /// مفاتيح الترجمة (عربي) — العرض بيتترجم حسب اللغة الحالية.
  final String nameKey;
  final String kindKey;
  final String image;
  final int price;
  final int qty;
  final int maxQty;

  /// اللون والطول، مثلاً ["فيروزي", "طويل 5 م"].
  final List<String> variantKeys;

  const CartItem({
    required this.id,
    required String name,
    required String kind,
    required this.image,
    required this.price,
    this.qty = 1,
    this.maxQty = 10,
    this.variantKeys = const [],
  }) : nameKey = name,
       kindKey = kind;

  String get name => nameKey.tr;
  String get kind => kindKey.tr;

  /// مثلاً: "فيروزي · طويل 5 م"
  String? get variant =>
      variantKeys.isEmpty ? null : variantKeys.map((k) => k.tr).join(' · ');

  factory CartItem.fromProduct(Product p, {int qty = 1}) => CartItem(
    id: p.id,
    name: p.nameKey,
    kind: p.kindKey,
    image: p.image,
    price: p.price,
    qty: qty,
  );

  factory CartItem.fromOrderItem(OrderItem i) => CartItem(
    id: 'order-${i.nameKey}-${i.kindKey}',
    name: i.nameKey,
    kind: i.kindKey,
    image: i.image,
    price: i.price,
    qty: i.qty,
  );

  int get lineTotal => price * qty;

  // ---------- الحفظ على الجهاز ----------
  Map<String, Object?> toJson() => {
    'id': id,
    'name': nameKey,
    'kind': kindKey,
    'image': image,
    'price': price,
    'qty': qty,
    'maxQty': maxQty,
    'variants': variantKeys,
  };

  /// null لو البيانات ناقصة أو تالفة (السطر ده بيتجاهل).
  static CartItem? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'], name = json['name'], kind = json['kind'];
    final image = json['image'], price = json['price'], qty = json['qty'];
    if (id is! String || name is! String || kind is! String) return null;
    if (image is! String || price is! int || qty is! int || qty < 1) {
      return null;
    }
    final maxQty = json['maxQty'] is int ? json['maxQty'] as int : 10;
    return CartItem(
      id: id,
      name: name,
      kind: kind,
      image: image,
      price: price,
      qty: qty.clamp(1, maxQty),
      maxQty: maxQty,
      variantKeys: [
        for (final v in (json['variants'] as List? ?? const []))
          if (v is String) v,
      ],
    );
  }

  OrderItem toOrderItem() => OrderItem(
    name: nameKey,
    kind: kindKey,
    image: image,
    price: price,
    qty: qty,
  );

  CartItem copyWith({int? qty}) => CartItem(
    id: id,
    name: nameKey,
    kind: kindKey,
    image: image,
    price: price,
    qty: qty ?? this.qty,
    maxQty: maxQty,
    variantKeys: variantKeys,
  );
}

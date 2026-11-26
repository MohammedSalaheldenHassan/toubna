import 'package:get/get.dart';

/// "منتج واحد / منتجان / 3 منتجات / 11 منتج" — "1 item / 3 items".
String itemsText(int count) {
  if (Get.locale?.languageCode == 'en') {
    return count == 1 ? '1 item' : '$count items';
  }
  if (count == 1) return 'منتج واحد';
  if (count == 2) return 'منتجان';
  if (count >= 3 && count <= 10) return '$count منتجات';
  return '$count منتج';
}

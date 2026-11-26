import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AddressLabel {
  home('المنزل', Icons.home_outlined),
  work('العمل', Icons.work_outline),
  other('أخرى', Icons.location_on_outlined);

  const AddressLabel(this.titleKey, this.icon);
  final String titleKey;
  final IconData icon;

  String get title => titleKey.tr;
}

/// ولايات السودان (لاختيار ولاية التوصيل).
const sudanStates = [
  'الخرطوم',
  'الجزيرة',
  'نهر النيل',
  'الشمالية',
  'البحر الأحمر',
  'كسلا',
  'القضارف',
  'سنار',
  'النيل الأبيض',
  'النيل الأزرق',
  'شمال كردفان',
  'جنوب كردفان',
  'غرب كردفان',
  'شمال دارفور',
  'جنوب دارفور',
  'شرق دارفور',
  'غرب دارفور',
  'وسط دارفور',
];

class Address {
  final String id;
  final AddressLabel label;
  final String recipient;
  final String phone;
  final String state;
  final String area;
  final String street;
  final String landmark;

  const Address({
    required this.id,
    required this.label,
    required this.recipient,
    required this.phone,
    required this.state,
    required this.area,
    required this.street,
    this.landmark = '',
  });

  /// "الخرطوم، الرياض — شارع المشتل، منزل 14"
  /// (الولاية بتتترجم، والحي والشارع زي ما كتبتهم المستخدمة)
  String get fullText => '@state، @area — @street'.trParams({
    'state': state.tr,
    'area': area.tr,
    'street': street.tr,
  });

  /// "الرياض، الخرطوم" للعرض المختصر.
  String get shortText =>
      '@area، @state'.trParams({'area': area.tr, 'state': state.tr});
}

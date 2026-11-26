import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/services/user_controller.dart';
import 'package:toubna/core/utils/app_message.dart';
import 'package:toubna/features/addresses/data/address.dart';
import 'package:toubna/features/addresses/presentation/controllers/addresses_controller.dart';

/// يفتح بـ Get.toNamed(AppRoutes.addressForm) للإضافة،
/// أو بـ arguments: address.id للتعديل.
class AddressFormController extends GetxController {
  final _addresses = Get.find<AddressesController>();

  final formKey = GlobalKey<FormState>();
  final recipientController = TextEditingController();
  final phoneController = TextEditingController();
  final areaController = TextEditingController();
  final streetController = TextEditingController();
  final landmarkController = TextEditingController();

  final label = AddressLabel.home.obs;
  final state = RxnString();
  final makeDefault = false.obs;

  Address? _editing;
  bool get isEditing => _editing != null;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments is String ? Get.arguments as String : null;
    _editing = id == null ? null : _addresses.byId(id);
    final a = _editing;
    if (a != null) {
      label.value = a.label;
      recipientController.text = a.recipient;
      phoneController.text = a.phone;
      state.value = a.state;
      areaController.text = a.area;
      streetController.text = a.street;
      landmarkController.text = a.landmark;
      makeDefault.value = _addresses.isDefault(a);
    } else {
      // عنوان جديد: نعبّي بيانات صاحبة الحساب كبداية
      final user = Get.find<UserController>();
      recipientController.text = user.name.value;
      phoneController.text = user.phone.value;
      state.value = 'الخرطوم'; // مفتاح القائمة (بيتترجم في العرض)
      makeDefault.value = _addresses.count == 0;
    }
  }

  // ---------- التحقق ----------
  String? required(String? value, String field) =>
      (value ?? '').trim().isEmpty ? 'اكتبي @p0'.trParams({'p0': field}) : null;

  /// أرقام سودانية: 9XXXXXXXX أو 1XXXXXXXX مع +249 أو 0 اختياريًا.
  String? validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (digits.isEmpty) return 'اكتبي رقم الموبايل'.tr;
    if (!RegExp(r'^(\+?249|0)?[19]\d{8}$').hasMatch(digits)) {
      return 'رقم غير صحيح، مثال: 912345678'.tr;
    }
    return null;
  }

  String? validateState(String? value) =>
      value == null ? 'اختاري الولاية'.tr : null;

  void save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final address = Address(
      id: _editing?.id ?? 'a${DateTime.now().microsecondsSinceEpoch}',
      label: label.value,
      recipient: recipientController.text.trim(),
      phone: phoneController.text.trim(),
      state: state.value!,
      area: areaController.text.trim(),
      street: streetController.text.trim(),
      landmark: landmarkController.text.trim(),
    );
    _addresses.save(address, makeDefault: makeDefault.value);
    Get.back();
    showAppMessage(isEditing ? 'تم تعديل العنوان'.tr : 'تمت إضافة العنوان'.tr);
  }

  @override
  void onClose() {
    recipientController.dispose();
    phoneController.dispose();
    areaController.dispose();
    streetController.dispose();
    landmarkController.dispose();
    super.onClose();
  }
}

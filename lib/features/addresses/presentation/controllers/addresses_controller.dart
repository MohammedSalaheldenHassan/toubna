import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/utils/app_message.dart';
import 'package:toubna/features/addresses/data/address.dart';

/// عناوين التوصيل على مستوى التطبيق (حسابي، صفحة العناوين، وبعدين الدفع).
class AddressesController extends GetxController {
  // بيانات تجريبية — لاحقًا تجي من الـ API
  final addresses = <Address>[
    const Address(
      id: 'a1',
      label: AddressLabel.home,
      recipient: 'صلاح الدين حسن',
      phone: '+249 912 900 089',
      state: 'الخرطوم',
      area: 'الرياض',
      street: 'شارع المشتل، منزل 14',
      landmark: 'جنب صيدلية النخيل',
    ),
    const Address(
      id: 'a2',
      label: AddressLabel.work,
      recipient: 'صلاح الدين حسن',
      phone: '+249 912 900 089',
      state: 'الخرطوم',
      area: 'الخرطوم 2',
      street: 'شارع الجمهورية، عمارة السلام، الطابق 3',
    ),
  ].obs;

  final defaultId = 'a1'.obs;

  int get count => addresses.length;

  Address? get defaultAddress => byId(defaultId.value);

  bool isDefault(Address a) => a.id == defaultId.value;

  Address? byId(String id) {
    for (final a in addresses) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// يضيف عنوان جديد أو يعدّل الموجود بنفس الـ id.
  void save(Address address, {bool makeDefault = false}) {
    // هنا لاحقًا: ترسل العنوان للـ API
    final index = addresses.indexWhere((a) => a.id == address.id);
    if (index == -1) {
      addresses.add(address);
    } else {
      addresses[index] = address;
    }
    // أول عنوان يبقى افتراضي تلقائيًا
    if (makeDefault || addresses.length == 1) defaultId.value = address.id;
  }

  void setDefault(Address a) {
    if (isDefault(a)) return;
    defaultId.value = a.id;
    showAppMessage(
      'تم تعيين "@p0" كعنوان افتراضي'.trParams({'p0': a.label.title}),
    );
  }

  void delete(Address a) {
    addresses.removeWhere((x) => x.id == a.id);
    if (defaultId.value == a.id) {
      defaultId.value = addresses.isEmpty ? '' : addresses.first.id;
    }
    showAppMessage('تم حذف العنوان'.tr);
  }

  void confirmDelete(Address a) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'حذف العنوان'.tr,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'متأكدة إنك عايزة تحذفي عنوان "@p0"؟\n@p1'.trParams({
            'p0': a.label.title,
            'p1': a.fullText,
          }),
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
            onPressed: () {
              Get.back();
              delete(a);
            },
            child: Text(
              'حذف'.tr,
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

  /// مع حذف الحساب.
  void clearAll() {
    addresses.clear();
    defaultId.value = '';
  }

  void openAdd() => Get.toNamed(AppRoutes.addressForm);

  void openEdit(Address a) =>
      Get.toNamed(AppRoutes.addressForm, arguments: a.id);
}

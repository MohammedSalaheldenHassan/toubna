import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/page_header.dart';
import 'package:toubna/features/addresses/data/address.dart';
import 'package:toubna/features/addresses/presentation/controllers/addresses_controller.dart';
import 'package:toubna/features/my_order/presentation/widgets/order_card.dart';

class LocationsScreen extends GetView<AddressesController> {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              PageHeader(
                title: "عناويني".tr,
                subtitle: "اختاري العنوان الافتراضي للتوصيل".tr,
              ),
              Expanded(
                child: Obx(() {
                  final list = controller.addresses;
                  if (list.isEmpty) return const _EmptyAddresses();
                  return ListView.separated(
                    padding: const EdgeInsets.only(top: 16, bottom: 20),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _AddressCard(address: list[i]),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: OrderButton.primary(
              label: 'إضافة عنوان جديد'.tr,
              icon: 'assets/icons/plus.png',
              onTap: controller.openAdd,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends GetView<AddressesController> {
  final Address address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDefault = controller.isDefault(address);
      return Semantics(
        selected: isDefault,
        child: Material(
          color: isDefault ? const Color(0xFFFDF8FA) : Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isDefault ? AppColors.primary : AppColors.border,
              width: isDefault ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => controller.setDefault(address),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          address.label.icon,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _details(isDefault)),
                      const SizedBox(width: 8),
                      _RadioDot(selected: isDefault),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      _action(
                        Icons.edit_outlined,
                        'تعديل'.tr,
                        AppColors.primary,
                        () => controller.openEdit(address),
                      ),
                      _action(
                        Icons.delete_outline,
                        'حذف'.tr,
                        AppColors.danger,
                        () => controller.confirmDelete(address),
                      ),
                      const Spacer(),
                      if (!isDefault)
                        Flexible(
                          child: TextButton(
                            onPressed: () => controller.setDefault(address),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'تعيين كافتراضي'.tr,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _details(bool isDefault) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              address.label.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'الافتراضي'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          address.fullText,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textBody,
          ),
        ),
        if (address.landmark.isNotEmpty)
          Text(
            address.landmark.tr,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        const SizedBox(height: 4),
        // \u2066…\u2069: الرقم يفضل من الشمال لليمين جوه النص العربي
        Text(
          '${address.recipient} · \u2066${address.phone}\u2069',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _action(IconData icon, String label, Color color, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;

  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFC9B8C0),
          width: 2,
        ),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _EmptyAddresses extends GetView<AddressesController> {
  const _EmptyAddresses();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(26),
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icons/location.png',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'مافي عناوين محفوظة'.tr,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'ضيفي عنوانك عشان نوصّل طلباتك بسرعة.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

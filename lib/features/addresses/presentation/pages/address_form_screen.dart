import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/choice_chip_button.dart';
import 'package:toubna/core/widgets/page_header.dart';
import 'package:toubna/features/addresses/data/address.dart';
import 'package:toubna/features/addresses/presentation/controllers/address_form_controller.dart';

class AddressFormScreen extends GetView<AddressFormController> {
  const AddressFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: controller.isEditing
                      ? 'تعديل العنوان'.tr
                      : 'عنوان جديد'.tr,
                  subtitle: 'بيانات التوصيل للمندوب'.tr,
                ),
                const SizedBox(height: 20),
                _Label('نوع العنوان'.tr),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final l in AddressLabel.values)
                        ChoiceChipButton(
                          label: l.title,
                          icon: l.icon,
                          selected: controller.label.value == l,
                          onTap: () => controller.label.value = l,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Label('اسم المستلمة'.tr),
                TextFormField(
                  controller: controller.recipientController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  validator: (v) => controller.required(v, 'اسم المستلمة'.tr),
                  decoration: _decoration(
                    hint: 'مثلاً: مريم أحمد'.tr,
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 16),
                _Label('رقم الموبايل'.tr),
                TextFormField(
                  controller: controller.phoneController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  validator: controller.validatePhone,
                  decoration: _decoration(
                    hint: '+249 9X XXX XXXX',
                    icon: Icons.phone_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                _Label('الولاية'.tr),
                DropdownButtonFormField<String>(
                  initialValue: controller.state.value,
                  isExpanded: true,
                  validator: controller.validateState,
                  onChanged: (v) => controller.state.value = v,
                  borderRadius: BorderRadius.circular(14),
                  dropdownColor: Colors.white,
                  menuMaxHeight: 360,
                  decoration: _decoration(
                    hint: 'اختاري الولاية'.tr,
                    icon: Icons.map_outlined,
                  ),
                  items: [
                    for (final s in sudanStates)
                      DropdownMenuItem(value: s, child: Text(s.tr)),
                  ],
                ),
                const SizedBox(height: 16),
                _Label('المدينة / الحي'.tr),
                TextFormField(
                  controller: controller.areaController,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      controller.required(v, 'المدينة أو الحي'.tr),
                  decoration: _decoration(
                    hint: 'مثلاً: الرياض'.tr,
                    icon: Icons.location_city_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                _Label('الشارع ورقم المنزل'.tr),
                TextFormField(
                  controller: controller.streetController,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      controller.required(v, 'الشارع ورقم المنزل'.tr),
                  decoration: _decoration(
                    hint: 'مثلاً: شارع المشتل، منزل 14'.tr,
                    icon: Icons.signpost_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                _Label('علامة مميزة (اختياري)'.tr),
                TextFormField(
                  controller: controller.landmarkController,
                  textInputAction: TextInputAction.done,
                  maxLines: 2,
                  minLines: 1,
                  decoration: _decoration(
                    hint: 'مثلاً: جنب صيدلية النخيل'.tr,
                    icon: Icons.flag_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: SwitchListTile(
                      value: controller.makeDefault.value,
                      onChanged: (v) => controller.makeDefault.value = v,
                      activeTrackColor: AppColors.primary,
                      activeThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFD8CDD2),
                      inactiveThumbColor: Colors.white,
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      title: Text(
                        'اجعليه العنوان الافتراضي'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: controller.save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  controller.isEditing ? 'حفظ التعديلات'.tr : 'حفظ العنوان'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // نفس شكل حقول "نسيتي كلمة المرور"
  InputDecoration _decoration({required String hint, required IconData icon}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: AppColors.textMuted),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    ),
  );
}

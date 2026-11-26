import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/primary_button.dart';
import 'package:toubna/features/account/presentation/controllers/delete_account_controller.dart';

/// شيت حذف الحساب: إيه اللي بيتحذف + كلمة المرور + تأكيد إنها فاهمة.
class DeleteAccountSheet extends StatelessWidget {
  const DeleteAccountSheet({super.key});

  static Future<void> show() async {
    await Get.bottomSheet(
      const DeleteAccountSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  static const _losses = [
    (Icons.receipt_long_outlined, 'سجل طلباتك'),
    (Icons.location_on_outlined, 'عناوينك المحفوظة'),
    (Icons.favorite_border, 'المفضلة'),
    (Icons.shopping_bag_outlined, 'المنتجات في السلة'),
  ];

  @override
  Widget build(BuildContext context) {
    // الكنترولر يتسجّل مع فتح الشيت ويتحذف لما يتقفل
    return GetBuilder<DeleteAccountController>(
      init: DeleteAccountController(),
      builder: (c) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9C9D0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDECEC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 36,
                      color: AppColors.danger,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'حذف الحساب نهائيًا'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'الحذف ما ممكن نتراجع عنه، وهتفقدي:'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      for (final (icon, text) in _losses)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Icon(icon, size: 20, color: AppColors.danger),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  text.tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textBody,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'اكتبي كلمة المرور للتأكيد'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => TextField(
                    controller: c.passwordController,
                    obscureText: c.hidePassword.value,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      filled: true,
                      fillColor: Colors.white,
                      errorText: c.errorText.value,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: c.togglePassword,
                        tooltip: c.hidePassword.value
                            ? 'إظهار كلمة المرور'.tr
                            : 'إخفاء كلمة المرور'.tr,
                        icon: Icon(
                          c.hidePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.danger,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => CheckboxListTile(
                    value: c.understood.value,
                    onChanged: (_) => c.toggleUnderstood(),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.danger,
                    title: Text(
                      'أفهم إن حذف الحساب نهائي وما ممكن أرجّعه'.tr,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => PrimaryButton(
                    label: 'حذف حسابي'.tr,
                    color: AppColors.danger,
                    loading: c.isDeleting.value,
                    onTap: c.canDelete || c.isDeleting.value
                        ? c.deleteAccount
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: Get.back,
                  child: Text(
                    'تراجع'.tr,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

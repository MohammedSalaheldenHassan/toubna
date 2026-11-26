import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/config/app_info.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/page_header.dart';

/// الشروط وسياسة الخصوصية.
///
/// ⚠️ نص مبدئي للتطبيق — لازم يراجعه مختص قانوني قبل النشر.
class TermsAndPrivacyPolicy extends StatelessWidget {
  const TermsAndPrivacyPolicy({super.key});

  static const _terms = [
    (
      'الحساب',
      'أنتِ مسؤولة عن صحة بياناتك وعن سرية كلمة المرور. بنأكد رقم الموبايل برمز عشان نحمي حسابك.',
    ),
    (
      'الطلبات والأسعار',
      'الأسعار بالجنيه السوداني وممكن تتغير، والسعر المعتمد هو اللي ظاهر وقت تأكيد الطلب.',
    ),
    (
      'التوصيل والدفع',
      'بنوصّل لكل الولايات، والدفع عند الاستلام نقدًا أو بتحويل للمندوب.',
    ),
    (
      'الإرجاع',
      'تقدري ترجّعي التوب خلال 7 أيام من الاستلام لو ما اتلبس وفي حالته الأصلية.',
    ),
  ];

  static const _privacy = [
    (
      'البيانات اللي بنجمعها',
      'اسمك، رقم موبايلك، بريدك، عناوين التوصيل، وطلباتك — بس اللي محتاجينه عشان نوصّل طلبك.',
    ),
    (
      'كيف بنستخدمها',
      'لتجهيز وتوصيل الطلبات، والتواصل معاك بخصوصها، وتحسين التطبيق. ما بنبيع بياناتك لأي جهة.',
    ),
    (
      'حقوقك',
      'تقدري تعدّلي بياناتك من الملف الشخصي، أو تحذفي حسابك وكل بياناتك نهائيًا من نفس الصفحة.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 24),
          children: [
            PageHeader(
              title: "الشروط وسياسة الخصوصية".tr,
              subtitle: 'آخر تحديث: @p0'.trParams({
                'p0': AppInfo.termsUpdated.tr,
              }),
            ),
            const SizedBox(height: 16),
            _Section(title: 'الشروط والأحكام'.tr, items: _terms),
            const SizedBox(height: 16),
            _Section(title: 'سياسة الخصوصية'.tr, items: _privacy),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<(String, String)> items;

  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          for (final (i, (heading, body)) in items.indexed) ...[
            const SizedBox(height: 12),
            Text(
              '${i + 1}. ${heading.tr}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body.tr,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: AppColors.textBody,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

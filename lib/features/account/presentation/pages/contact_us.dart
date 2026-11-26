import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/config/app_info.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/utils/external_links.dart';
import 'package:toubna/core/widgets/page_header.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  static const _faq = [
    (
      'التوصيل بياخد قد إيه؟',
      'داخل الخرطوم من يوم ليومين، ولباقي الولايات من 3 لـ 5 أيام عمل.',
    ),
    (
      'كيف أدفع؟',
      'الدفع عند الاستلام: نقدًا أو بتحويل بنكك للمندوب لما يوصلك الطلب.',
    ),
    (
      'ممكن أرجّع التوب؟',
      'أيوه، خلال 7 أيام من الاستلام لو التوب ما اتلبس وفي حالته الأصلية.',
    ),
    (
      'أعرف الطول المناسب ليا كيف؟',
      'الطول القياسي 4.5 م يناسب أغلب المقاسات. لو محتارة، راسلينا في واتساب ونساعدك.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 24),
          children: [
            PageHeader(title: "تواصلي معنا".tr),
            const SizedBox(height: 16),
            Text(
              'يسعدنا نساعدك في أي وقت — اختاري الطريقة الأنسب ليك.'.tr,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.textBody,
              ),
            ),
            const SizedBox(height: 16),
            _ContactCard(
              icon: Icons.chat_outlined,
              color: const Color(0xFF1E8E3E),
              title: 'واتساب'.tr,
              subtitle: 'أسرع طريقة للرد'.tr,
              onTap: () => openExternal(
                Uri.parse('https://wa.me/${AppInfo.whatsappNumber}'),
                copyValue: AppInfo.supportPhone,
              ),
            ),
            const SizedBox(height: 10),
            _ContactCard(
              icon: Icons.call_outlined,
              color: AppColors.primary,
              title: 'اتصلي بينا'.tr,
              subtitle: AppInfo.supportPhone,
              ltrSubtitle: true,
              onTap: () => openExternal(
                Uri(
                  scheme: 'tel',
                  path: AppInfo.supportPhone.replaceAll(' ', ''),
                ),
                copyValue: AppInfo.supportPhone,
              ),
            ),
            const SizedBox(height: 10),
            _ContactCard(
              icon: Icons.mail_outline,
              color: const Color(0xFF3B2F6B),
              title: 'راسلينا بالإيميل'.tr,
              subtitle: AppInfo.supportEmail,
              ltrSubtitle: true,
              onTap: () => openExternal(
                Uri(scheme: 'mailto', path: AppInfo.supportEmail),
                copyValue: AppInfo.supportEmail,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.schedule,
                    text: 'يوميًا من 9:00 ص لـ 10:00 م'.tr,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.storefront_outlined,
                    text: 'الخرطوم، الرياض — شارع المشتل'.tr,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'أسئلة شائعة'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            for (final (q, a) in _faq)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    shape: const Border(),
                    iconColor: AppColors.primary,
                    title: Text(
                      q.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool ltrSubtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.ltrSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      textDirection: ltrSubtitle ? TextDirection.ltr : null,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}

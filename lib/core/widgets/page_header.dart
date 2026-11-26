import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/directional_arrow.dart';
import 'package:get/get.dart';

/// رأس الصفحات الفرعية: زر رجوع + عنوان (+ وصف اختياري).
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PageHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: 'رجوع'.tr,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
              side: const BorderSide(color: Color(0xffEADFE3)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Get.back(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: const DirectionalArrow(back: true),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 17)),
            ],
          ),
        ),
      ],
    );
  }
}

/// صفحة فرعية بسيطة: رأس + محتوى، مع الهوامش المعتمدة في التطبيق.
class SubPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? child;

  const SubPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              PageHeader(title: title, subtitle: subtitle),
              if (child != null) Expanded(child: child!),
            ],
          ),
        ),
      ),
    );
  }
}

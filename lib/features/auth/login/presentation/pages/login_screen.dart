import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:toubna/features/auth/login/presentation/controllers/login_controller.dart';
import 'package:toubna/features/auth/login/presentation/widgets/custom_button.dart';
import 'package:toubna/features/auth/login/presentation/widgets/custom_text_form.dart';
import 'package:toubna/features/auth/login/presentation/widgets/logo.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            const Logo(),
            const SizedBox(height: 20),
            const CustomTextForm(),
            const SizedBox(height: 20),
            const CustomButton(),
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.all(8.0), child: Text("أو".tr)),
                  Expanded(child: Divider()),
                ],
              ),
            ),
            // Wrap ينزل الرابط لسطر جديد على الشاشات الضيقة جدًا
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text("ليس لديكي حساب؟".tr, style: TextStyle(fontSize: 13)),
                TextButton(
                  onPressed: controller.goToRegister,
                  child: Text(
                    "إنشاء حساب".tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff7A1F4B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SafeArea(child: TermsFooter()),
    );
  }
}

/// سطر الموافقة على الشروط أسفل شاشات الدخول والتسجيل.
class TermsFooter extends StatelessWidget {
  const TermsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
      color: Color(0xff7A1F4B),
      fontSize: 11,
      fontWeight: FontWeight.w800,
    );
    return InkWell(
      // يفتح صفحة الشروط وسياسة الخصوصية
      onTap: () => Get.toNamed(AppRoutes.terms),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        // Text.rich يلتف لسطر ثاني على الشاشات الضيقة بدل ما يطلع برا
        child: Text.rich(
          TextSpan(
            style: TextStyle(color: Color(0xff6B5E66), fontSize: 11),
            children: [
              TextSpan(text: "بالمتابعة أنتِ توافقين على ".tr),
              TextSpan(text: "الشروط والأحكام".tr, style: linkStyle),
              TextSpan(text: " و".tr),
              TextSpan(text: "سياسة الخصوصية".tr, style: linkStyle),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

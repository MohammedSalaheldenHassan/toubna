import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/features/auth/login/presentation/pages/login_screen.dart';
import 'package:toubna/features/auth/register/presentation/controllers/register_controller.dart';
import 'package:toubna/features/auth/register/presentation/widgets/register_button.dart';
import 'package:toubna/features/auth/register/presentation/widgets/register_form.dart';
import 'package:toubna/features/auth/register/presentation/widgets/term.dart';
import 'package:toubna/features/auth/register/presentation/widgets/top_bar.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            const TopBar(),
            const RegisterForm(),
            const SizedBox(height: 10),
            const Term(),
            const SizedBox(height: 10),
            const RegisterButton(),
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
                Text(" لديكي حساب؟".tr, style: TextStyle(fontSize: 13)),
                TextButton(
                  onPressed: controller.goToLogin,
                  child: Text(
                    "تسجيل الدخول".tr,
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

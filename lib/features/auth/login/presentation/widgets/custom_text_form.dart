import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/utils/validators.dart';
import 'package:toubna/features/auth/login/presentation/controllers/login_controller.dart';
import 'package:toubna/features/auth/login/presentation/widgets/auth_field.dart';
import 'package:toubna/features/auth/login/presentation/widgets/forget_password.dart';

class CustomTextForm extends GetView<LoginController> {
  const CustomTextForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Form(
        key: controller.formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "أهلاً بك".tr,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "سجّلي دخولك لمتابعة طلباتك".tr,
                style: TextStyle(fontSize: 14, color: Color(0xff6B5E66)),
              ),
              const SizedBox(height: 15),
              AuthField(
                label: "البريد الالكتروني".tr,
                hint: "ادخل بريدك الالكتروني".tr,
                icon: Icons.email_outlined,
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textDirection: TextDirection.ltr,
                validator: Validators.email,
              ),
              const SizedBox(height: 15),
              Obx(
                () => AuthField(
                  label: "كلمة المرور".tr,
                  hint: "ادخل كلمة المرور ".tr,
                  icon: Icons.password_outlined,
                  controller: controller.passwordController,
                  textInputAction: TextInputAction.done,
                  obscureText: controller.hidePassword.value,
                  autofillHints: const [AutofillHints.password],
                  validator: Validators.password,
                  suffix: PasswordToggle(
                    hidden: controller.hidePassword.value,
                    onPressed: controller.togglePassword,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextButton(
                onPressed: () => ForgotPasswordSheet.show(context),
                child: Text(
                  "هل نسيت كلمة المرور؟".tr,
                  style: TextStyle(fontSize: 14, color: Color(0xff7A1F4B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

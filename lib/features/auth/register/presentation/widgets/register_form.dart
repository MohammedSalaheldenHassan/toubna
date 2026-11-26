import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/utils/validators.dart';
import 'package:toubna/features/auth/login/presentation/widgets/auth_field.dart';
import 'package:toubna/features/auth/register/presentation/controllers/register_controller.dart';

class RegisterForm extends GetView<RegisterController> {
  const RegisterForm({super.key});

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
              const SizedBox(height: 15),
              AuthField(
                label: "الاسم الكامل".tr,
                hint: "مثلاً: مريم أحمد".tr,
                icon: Icons.person_2_outlined,
                controller: controller.nameController,
                keyboardType: TextInputType.name,
                autofillHints: const [AutofillHints.name],
                validator: Validators.name,
              ),
              const SizedBox(height: 15),
              AuthField(
                label: "البريد الإلكتروني".tr,
                hint: "mariam@example.com",
                icon: Icons.email_outlined,
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textDirection: TextDirection.ltr,
                validator: Validators.email,
              ),
              const SizedBox(height: 15),
              AuthField(
                label: "رقم الموبايل (للتواصل عند التوصيل)".tr,
                hint: "9X XXX XXXX",
                icon: Icons.numbers,
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                textDirection: TextDirection.ltr,
                validator: Validators.phone,
              ),
              const SizedBox(height: 15),
              Obx(
                () => AuthField(
                  label: "كلمة المرور".tr,
                  hint: "ادخل كلمة المرور ".tr,
                  icon: Icons.password_outlined,
                  controller: controller.passwordController,
                  obscureText: controller.hidePassword.value,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: Validators.newPassword,
                  suffix: PasswordToggle(
                    hidden: controller.hidePassword.value,
                    onPressed: controller.togglePassword,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Obx(
                () => AuthField(
                  label: "تأكيد كلمة المرور".tr,
                  hint: "ادخل كلمة المرور ".tr,
                  icon: Icons.password_outlined,
                  controller: controller.confirmController,
                  textInputAction: TextInputAction.done,
                  obscureText: controller.hideConfirm.value,
                  validator: controller.validateConfirm,
                  suffix: PasswordToggle(
                    hidden: controller.hideConfirm.value,
                    onPressed: controller.toggleConfirm,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

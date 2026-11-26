import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// حقل الإدخال المستخدم في شاشتي الدخول والتسجيل (نفس الشكل الأصلي).
class AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final TextDirection? textDirection;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.autofillHints,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    // نفس الشكل الأصلي (إطار عنابي، زوايا 14) بس الإطار جزء من الحقل،
    // عشان رسالة الخطأ تظهر تحته
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          autofillHints: autofillHints,
          textDirection: textDirection,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hint: Text(hint, style: const TextStyle(fontSize: 15)),
            prefixIcon: Icon(icon),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: border(const Color(0xff7A1F4B)),
            focusedBorder: border(const Color(0xff7A1F4B), 1.8),
            errorBorder: border(const Color(0xffA61B1B)),
            focusedErrorBorder: border(const Color(0xffA61B1B), 1.8),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

/// زر إظهار/إخفاء كلمة المرور.
class PasswordToggle extends StatelessWidget {
  final bool hidden;
  final VoidCallback onPressed;

  const PasswordToggle({
    super.key,
    required this.hidden,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: hidden ? 'إظهار كلمة المرور'.tr : 'إخفاء كلمة المرور'.tr,
      icon: Icon(
        hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: const Color(0xFF6B5E66),
      ),
    );
  }
}

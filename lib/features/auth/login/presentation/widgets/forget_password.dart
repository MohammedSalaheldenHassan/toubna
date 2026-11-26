import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/directional_arrow.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toubna/features/auth/login/presentation/controllers/forgot_password_controller.dart';

class ForgotPasswordSheet extends StatelessWidget {
  const ForgotPasswordSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFBF7F4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const ForgotPasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // الكنترولر يتسجّل مع فتح الشيت ويتحذف (onClose) لما الشيت يتقفل
    return GetBuilder<ForgotPasswordController>(
      init: ForgotPasswordController(),
      builder: (c) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topBar(c),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: switch (c.step) {
                    0 => _emailStep(c),
                    1 => _codeStep(c),
                    2 => _newPassStep(c),
                    _ => _doneStep(context),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- الشريط اللي فوق ----------
  Widget _topBar(ForgotPasswordController c) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFD9C9D0),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (c.step == 1 || c.step == 2)
              IconButton(
                onPressed: c.back,
                icon: const DirectionalArrow(back: true, icon: true, size: 22),
              )
            else
              const SizedBox(width: 48),
            const Spacer(),
            if (c.step < 3)
              Row(
                children: List.generate(3, (i) {
                  final active = i == c.step;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i <= c.step
                          ? const Color(0xFF7A1F4B)
                          : const Color(0xFFD9B9C8),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
          ],
        ),
      ],
    );
  }

  // ---------- الخطوة 1: البريد ----------
  Widget _emailStep(ForgotPasswordController c) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _iconBox('assets/icons/mail.png'),
        const SizedBox(height: 16),
        _title('نسيتي كلمة المرور؟'.tr),
        const SizedBox(height: 6),
        _body('اكتبي البريد اللي سجّلتي بيه، وهنرسل ليك رمز من 4 أرقام.'.tr),
        const SizedBox(height: 20),
        _label('البريد الإلكتروني'.tr),
        _field(
          controller: c.emailController,
          hint: 'name@example.com',
          icon: 'assets/icons/mail.png',
          keyboard: TextInputType.emailAddress,
          errorText: c.emailError,
        ),
        const SizedBox(height: 20),
        _primaryButton('إرسال الرمز'.tr, c.sendCode),
      ],
    );
  }

  // ---------- الخطوة 2: الرمز ----------
  Widget _codeStep(ForgotPasswordController c) {
    return Column(
      key: const ValueKey(1),
      children: [
        _iconBox('assets/icons/mail.png', size: 88, center: true),
        const SizedBox(height: 16),
        _title('أدخلي رمز التحقق'.tr),
        const SizedBox(height: 6),
        _body(
          'أرسلنا رمز من 4 أرقام إلى\n@p0'.trParams({'p0': c.maskedEmail}),
          center: true,
        ),
        const SizedBox(height: 24),

        // خانات الرمز (من الشمال لليمين زي الأرقام)
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(ForgotPasswordController.codeLength, (i) {
              return Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 60),
                  height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: TextField(
                    controller: c.codeControllers[i],
                    focusNode: c.codeFocus[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '', // يشيل عداد الحروف
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFEADFE3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF7A1F4B),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => c.onCodeChanged(i, value),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: _primaryButton(
            'تأكيد الرمز'.tr,
            c.isCodeComplete ? c.verifyCode : null,
          ),
        ),
        const SizedBox(height: 8),

        // إعادة الإرسال
        c.secondsLeft > 0
            ? Text(
                'إعادة الإرسال بعد 0:@p0'.trParams({
                  'p0': c.secondsLeft.toString().padLeft(2, '0'),
                }),
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B5E66)),
              )
            : TextButton(
                onPressed: c.resendCode,
                child: Text(
                  'ما وصلك؟ إعادة الإرسال'.tr,
                  style: TextStyle(
                    color: Color(0xFF7A1F4B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ],
    );
  }

  // ---------- الخطوة 3: كلمة مرور جديدة ----------
  Widget _newPassStep(ForgotPasswordController c) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title('كلمة مرور جديدة'.tr),
        const SizedBox(height: 6),
        _body('اختاري كلمة مرور مختلفة عن القديمة.'.tr),
        const SizedBox(height: 20),
        _label('كلمة المرور الجديدة'.tr),
        _field(
          controller: c.passController,
          hint: '••••••••',
          icon: 'assets/icons/settings.png',
          obscure: c.hidePass,
          suffix: IconButton(
            onPressed: c.togglePass,
            icon: Icon(
              c.hidePass
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF6B5E66),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _label('تأكيد كلمة المرور'.tr),
        _field(
          controller: c.confirmController,
          hint: '••••••••',
          icon: 'assets/icons/settings.png',
          obscure: true,
        ),
        const SizedBox(height: 20),
        _primaryButton('حفظ كلمة المرور'.tr, c.savePassword),
      ],
    );
  }

  // ---------- الخطوة 4: تم ----------
  Widget _doneStep(BuildContext context) {
    return Column(
      key: const ValueKey(3),
      children: [
        const SizedBox(height: 10),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFF7A1F4B),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFF3E4EB),
              width: 12,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 26),
        _title('تم تغيير كلمة المرور'.tr),
        const SizedBox(height: 6),
        _body(
          'تقدري تسجّلي دخولك دلوقتي بكلمة المرور الجديدة.'.tr,
          center: true,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: _primaryButton(
            'تسجيل الدخول'.tr,
            () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  // ---------- مساعدات ----------
  Widget _iconBox(String icon, {double size = 72, bool center = false}) {
    return Align(
      alignment: center ? Alignment.center : AlignmentDirectional.centerStart,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF3E4EB),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: ImageIcon(
            AssetImage(icon),
            size: size * 0.5,
            color: const Color(0xFF7A1F4B),
          ),
        ),
      ),
    );
  }

  Widget _title(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'ReemKufi',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF221A22),
    ),
  );

  Widget _body(String text, {bool center = false}) => Text(
    text,
    textAlign: center ? TextAlign.center : TextAlign.start,
    style: const TextStyle(fontSize: 14, height: 1.8, color: Color(0xFF6B5E66)),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF221A22),
      ),
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required String icon,
    TextInputType? keyboard,
    bool obscure = false,
    Widget? suffix,
    String? errorText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFEADFE3)),
    );
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: ImageIcon(
          AssetImage(icon),
          size: 20,
          color: const Color(0xFF6B5E66),
        ),
        suffixIcon: suffix,
        errorText: errorText,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: Color(0xFF7A1F4B), width: 1.5),
        ),
      ),
    );
  }

  Widget _primaryButton(String text, VoidCallback? onTap) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap, // null = الزر مقفول
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7A1F4B),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFEADFE3),
          disabledForegroundColor: const Color(0xFF6B5E66),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

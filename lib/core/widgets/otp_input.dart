import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toubna/core/theme/app_colors.dart';

/// خانات رمز التحقق. حقل واحد مخفي بيستقبل الأرقام (عشان اللصق والملء
/// التلقائي من رسالة SMS يشتغلوا)، والخانات بتعرضها.
class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final bool hasError;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpInput({
    super.key,
    required this.controller,
    required this.focusNode,
    this.length = 4,
    this.hasError = false,
    this.enabled = true,
    this.onChanged,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'رمز التحقق',
      textField: true,
      child: GestureDetector(
        onTap: enabled ? focusNode.requestFocus : null,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الحقل الحقيقي (شفاف) — بياخد الكتابة واللصق والـ autofill
            Opacity(
              opacity: 0,
              child: SizedBox(
                height: 64,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: enabled,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  maxLength: length,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(counterText: ''),
                  onChanged: (v) {
                    onChanged?.call(v);
                    if (v.length == length) onCompleted?.call(v);
                  },
                ),
              ),
            ),
            // الخانات (من الشمال لليمين زي الأرقام في اللغتين)
            IgnorePointer(
              child: ListenableBuilder(
                listenable: Listenable.merge([controller, focusNode]),
                builder: (context, _) {
                  final text = controller.text;
                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(length, (i) {
                        final filled = i < text.length;
                        final active =
                            focusNode.hasFocus &&
                            (i == text.length ||
                                (text.length == length && i == length - 1));
                        final color = hasError
                            ? AppColors.danger
                            : active
                            ? AppColors.primary
                            : filled
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.border;
                        return Flexible(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            constraints: const BoxConstraints(maxWidth: 60),
                            height: 64,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: color,
                                width: active || hasError ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              filled ? text[i] : '',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

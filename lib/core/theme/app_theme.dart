import 'package:flutter/material.dart';
import 'package:toubna/core/theme/app_colors.dart';

abstract final class AppTheme {
  static const fontFamily = 'IBMPlexSansArabic';
  static const displayFontFamily = 'ReemKufi';

  /// نفس الثيم الفاتح الأصلي، مع توحيد اللون الأساسي (المؤشر، التحديد،
  /// تأثير الضغط، الرسائل) على لون الهوية بدل البنفسجي الافتراضي.
  static ThemeData get light {
    // نفس ThemeData.light() بس بخط الهوية كافتراضي لكل التطبيق
    final base = ThemeData(
      brightness: Brightness.light,
      fontFamily: fontFamily,
    );
    // خط IBM Plex Sans Arabic للنصوص (ReemKufi للعناوين الكبيرة بالاسم)
    final textTheme = base.textTheme.apply(fontFamily: fontFamily);
    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: fontFamily),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.gold,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primarySoft,
        selectionHandleColor: AppColors.primary,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

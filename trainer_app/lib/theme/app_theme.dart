import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color primaryColor;
  final Color primaryLightColor;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;

  CustomThemeExtension({
    required this.primaryColor,
    required this.primaryLightColor,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
  });

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Color? primaryColor,
    Color? primaryLightColor,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
  }) {
    return CustomThemeExtension(
      primaryColor: primaryColor ?? this.primaryColor,
      primaryLightColor: primaryLightColor ?? this.primaryLightColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(
      ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      primaryLightColor: Color.lerp(primaryLightColor, other.primaryLightColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
    );
  }
}

class AppTheme {
  static CustomThemeExtension guruExtensionLight = CustomThemeExtension(
    primaryColor: AppColors.guruPrimary,
    primaryLightColor: AppColors.guruPrimaryLight,
    successColor: AppColors.success,
    warningColor: AppColors.warning,
    errorColor: AppColors.error,
  );

  static CustomThemeExtension trainerExtensionLight = CustomThemeExtension(
    primaryColor: AppColors.trainerPrimary,
    primaryLightColor: AppColors.trainerPrimaryLight,
    successColor: AppColors.success,
    warningColor: AppColors.warning,
    errorColor: AppColors.error,
  );

  static ThemeData getGuruTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.guruPrimary,
      scaffoldBackgroundColor: AppColors.bgLight,
      cardColor: AppColors.cardLight,
      extensions: [guruExtensionLight],
      textTheme: const TextTheme(
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        labelSmall: AppTypography.caption,
      ).apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      colorScheme: ColorScheme.light(
        primary: AppColors.guruPrimary,
        onPrimary: Colors.white,
        surface: AppColors.cardLight,
        onSurface: AppColors.textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData getTrainerTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.trainerPrimary,
      scaffoldBackgroundColor: AppColors.bgLight,
      cardColor: AppColors.cardLight,
      extensions: [trainerExtensionLight],
      textTheme: const TextTheme(
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        labelSmall: AppTypography.caption,
      ).apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      colorScheme: ColorScheme.light(
        primary: AppColors.trainerPrimary,
        onPrimary: Colors.white,
        surface: AppColors.cardLight,
        onSurface: AppColors.textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

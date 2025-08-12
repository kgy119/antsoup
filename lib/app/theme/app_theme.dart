import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',

      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        primaryContainer: AppColors.lightPrimaryVariant,
        secondary: AppColors.lightSecondary,
        secondaryContainer: AppColors.lightSecondaryVariant,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        error: AppColors.error,
        onPrimary: AppColors.lightOnPrimary,
        onSecondary: AppColors.lightOnSecondary,
        onSurface: AppColors.lightOnSurface,
        onBackground: AppColors.lightOnBackground,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.lightBackground,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.headline6.copyWith(
          color: AppColors.lightOnSurface,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1,
        displayMedium: AppTextStyles.headline2,
        displaySmall: AppTextStyles.headline3,
        headlineLarge: AppTextStyles.headline4,
        headlineMedium: AppTextStyles.headline5,
        headlineSmall: AppTextStyles.headline6,
        bodyLarge: AppTextStyles.bodyText1,
        bodyMedium: AppTextStyles.bodyText2,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',

      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        primaryContainer: AppColors.darkPrimaryVariant,
        secondary: AppColors.darkSecondary,
        secondaryContainer: AppColors.darkSecondaryVariant,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        error: AppColors.error,
        onPrimary: AppColors.darkOnPrimary,
        onSecondary: AppColors.darkOnSecondary,
        onSurface: AppColors.darkOnSurface,
        onBackground: AppColors.darkOnBackground,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.headline6.copyWith(
          color: AppColors.darkOnSurface,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.darkOnSurface),
        displayMedium: AppTextStyles.headline2.copyWith(color: AppColors.darkOnSurface),
        displaySmall: AppTextStyles.headline3.copyWith(color: AppColors.darkOnSurface),
        headlineLarge: AppTextStyles.headline4.copyWith(color: AppColors.darkOnSurface),
        headlineMedium: AppTextStyles.headline5.copyWith(color: AppColors.darkOnSurface),
        headlineSmall: AppTextStyles.headline6.copyWith(color: AppColors.darkOnSurface),
        bodyLarge: AppTextStyles.bodyText1.copyWith(color: AppColors.darkOnSurface),
        bodyMedium: AppTextStyles.bodyText2.copyWith(color: AppColors.darkOnSurface),
        bodySmall: AppTextStyles.caption.copyWith(color: AppColors.darkOnSurface),
        labelLarge: AppTextStyles.button,
      ),
    );
  }
}
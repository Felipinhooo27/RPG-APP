import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Tema principal do app Hexatombe
/// Design minimalista: SEM elevation, SEM borderRadius
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepBlack,
      primaryColor: AppColors.scarletRed,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.scarletRed,
        secondary: AppColors.magenta,
        surface: AppColors.darkGray,
        background: AppColors.deepBlack,
        error: AppColors.neonRed,
        onPrimary: AppColors.lightGray,
        onSecondary: AppColors.lightGray,
        onSurface: AppColors.lightGray,
        onBackground: AppColors.lightGray,
        onError: AppColors.lightGray,
      ),

      // AppBar - SEM elevation, com linha fina vermelha
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.title,
        iconTheme: IconThemeData(color: AppColors.scarletRed),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // Card - SEM elevation, SEM borderRadius
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        color: AppColors.darkGray,
        margin: EdgeInsets.zero,
      ),

      // Elevated Button - SEM elevation, SEM borderRadius
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.scarletRed,
          foregroundColor: AppColors.lightGray,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Outlined Button - SEM borderRadius
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.scarletRed, width: 1),
          foregroundColor: AppColors.scarletRed,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Text Button - minimalista
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.scarletRed,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTextStyles.button,
        ),
      ),

      // FAB - SEM elevation
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.scarletRed,
        foregroundColor: AppColors.lightGray,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),

      // Bottom Navigation Bar - inline
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.deepBlack,
        selectedItemColor: AppColors.scarletRed,
        unselectedItemColor: AppColors.silver,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.label,
        unselectedLabelStyle: AppTextStyles.label,
      ),

      // Tab Bar - linha fina vermelha
      tabBarTheme: const TabBarThemeData(
        indicatorColor: AppColors.scarletRed,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.scarletRed,
        unselectedLabelColor: AppColors.silver,
        labelStyle: AppTextStyles.labelMedium,
        unselectedLabelStyle: AppTextStyles.labelMedium,
      ),

      // Input Decoration - inline, sem bordas arredondadas
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.silver, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.silver, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.scarletRed, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.neonRed, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.neonRed, width: 2),
        ),
        labelStyle: AppTextStyles.bodySmall,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.silver.withOpacity(0.5)),
        errorStyle: AppTextStyles.error,
      ),

      // Dialog - SEM borderRadius
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkGray,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        titleTextStyle: AppTextStyles.title,
        contentTextStyle: AppTextStyles.body,
      ),

      // Divider - linha fina prata
      dividerTheme: const DividerThemeData(
        color: AppColors.silver,
        thickness: 1,
        space: 1,
      ),

      // Slider - cores Hexatombe
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.scarletRed,
        inactiveTrackColor: AppColors.silver.withOpacity(0.3),
        thumbColor: AppColors.scarletRed,
        overlayColor: AppColors.scarletRed.withOpacity(0.2),
        valueIndicatorColor: AppColors.scarletRed,
        valueIndicatorTextStyle: AppTextStyles.labelMedium,
      ),

      // Checkbox - quadrado
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.scarletRed;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.lightGray),
        side: const BorderSide(color: AppColors.silver, width: 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),

      // Radio - círculo com borda
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.scarletRed;
          }
          return AppColors.silver;
        }),
      ),

      // Switch - minimalista
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.scarletRed;
          }
          return AppColors.silver;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.scarletRed.withOpacity(0.5);
          }
          return AppColors.silver.withOpacity(0.3);
        }),
      ),

      // Progress Indicator - vermelho
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.scarletRed,
        linearTrackColor: AppColors.silver,
      ),

      // Snackbar - inline
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkGray,
        contentTextStyle: AppTextStyles.body,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),

      // Tipografia padrão
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.titleLarge,
        displayMedium: AppTextStyles.title,
        displaySmall: AppTextStyles.titleSmall,
        headlineLarge: AppTextStyles.titleLarge,
        headlineMedium: AppTextStyles.title,
        headlineSmall: AppTextStyles.titleSmall,
        titleLarge: AppTextStyles.uppercaseLarge,
        titleMedium: AppTextStyles.uppercase,
        titleSmall: AppTextStyles.labelMedium,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.label,
      ),
    );
  }
}

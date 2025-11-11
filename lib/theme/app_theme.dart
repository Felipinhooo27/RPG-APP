import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hexatombe Theme - Complete color palette and typography system
/// Based on the Ordem Paranormal: Hexatombe visual identity
class AppTheme {
  // ============================================================================
  // HEXATOMBE COLOR PALETTE
  // ============================================================================

  /// Primary Colors - Hexatombe Minimalist Palette
  static const Color scarletRed = Color(0xFFB50D0D);       // Vermelho Escarlate (primary)
  static const Color deepBlack = Color(0xFF0D0D0D);        // Preto Profundo (background)
  static const Color darkGray = Color(0xFF1A1A1A);         // Cinza Escuro (surface)

  /// Secondary Colors - Metallic accents
  static const Color silver = Color(0xFFC0C0C0);           // Prata (borders, icons)
  static const Color iron = Color(0xFF7A7A7A);             // Ferro (secondary text)
  static const Color steel = Color(0xFF404040);            // Aço (dividers)

  /// Text Colors
  static const Color pureWhite = Color(0xFFFAFAFA);        // Branco Puro (main text)
  static const Color lightGray = Color(0xFFE0E0E0);        // Cinza Claro (secondary text)

  /// Accent Colors - Status and effects
  static const Color bloodRed = Color(0xFF8B0000);         // Vermelho Sangue (dark variant)
  static const Color alertYellow = Color(0xFFD1A040);      // Amarelo Alerta (damage, warning)
  static const Color mutagenGreen = Color(0xFF468B45);     // Verde Mutagênico (heal, buffs)

  /// Legacy colors (for backward compatibility - to be removed)
  static const Color ritualRed = scarletRed;
  static const Color abyssalBlack = deepBlack;
  static const Color obscureGray = darkGray;
  static const Color paleWhite = pureWhite;
  static const Color coldGray = iron;
  static const Color limestoneGray = silver;
  static const Color industrialGray = steel;
  static const Color chaoticMagenta = Color(0xFF842047);
  static const Color etherealPurple = Color(0xFF3C235B);

  /// Gradient Definitions
  static const LinearGradient scarletGradient = LinearGradient(
    colors: [scarletRed, bloodRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [deepBlack, darkGray],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient metalGradient = LinearGradient(
    colors: [steel, darkGray],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Legacy gradients (backward compatibility)
  static const LinearGradient ritualGradient = scarletGradient;
  static const LinearGradient abyssGradient = darkGradient;
  static const LinearGradient occultGradient = metalGradient;

  // ============================================================================
  // TYPOGRAPHY CONFIGURATION
  // ============================================================================

  /// Returns the complete TextTheme with Hexatombe fonts
  static TextTheme get _textTheme {
    return TextTheme(
      // Display - Bebas Neue (Large titles, hero text)
      displayLarge: GoogleFonts.bebasNeue(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: paleWhite,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.bebasNeue(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: paleWhite,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.bebasNeue(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: paleWhite,
        height: 1.22,
      ),

      // Headline - Montserrat Bold (Section headers, cards)
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: paleWhite,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: paleWhite,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: paleWhite,
        height: 1.33,
      ),

      // Title - Montserrat SemiBold (Subtitles, labels)
      titleLarge: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: paleWhite,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: paleWhite,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: paleWhite,
        height: 1.43,
      ),

      // Body - Inter Regular (Main text content)
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: paleWhite,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: paleWhite,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: coldGray,
        height: 1.33,
      ),

      // Label - Space Mono (Numbers, stats, technical data)
      labelLarge: GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: paleWhite,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.spaceMono(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: paleWhite,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.spaceMono(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: coldGray,
        height: 1.45,
      ),
    );
  }

  // ============================================================================
  // MAIN THEME CONFIGURATION
  // ============================================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        // Primary
        primary: ritualRed,
        onPrimary: paleWhite,
        primaryContainer: Color(0xFF8B1917),
        onPrimaryContainer: paleWhite,

        // Secondary
        secondary: chaoticMagenta,
        onSecondary: paleWhite,
        secondaryContainer: etherealPurple,
        onSecondaryContainer: paleWhite,

        // Tertiary
        tertiary: etherealPurple,
        onTertiary: paleWhite,

        // Error
        error: ritualRed,
        onError: paleWhite,
        errorContainer: Color(0xFF8B1917),
        onErrorContainer: alertYellow,

        // Background & Surface
        background: abyssalBlack,
        onBackground: paleWhite,
        surface: obscureGray,
        onSurface: paleWhite,
        surfaceVariant: industrialGray,
        onSurfaceVariant: limestoneGray,

        // Outline
        outline: industrialGray,
        outlineVariant: coldGray,

        // Other
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: paleWhite,
        onInverseSurface: abyssalBlack,
        inversePrimary: ritualRed,
      ),

      // Scaffold
      scaffoldBackgroundColor: abyssalBlack,

      // Text Theme
      textTheme: _textTheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: obscureGray,
        foregroundColor: paleWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: paleWhite,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(
          color: paleWhite,
          size: 24,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Card Theme - Minimalist, no rounded borders
      cardTheme: CardThemeData(
        color: darkGray,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // No rounded borders
          side: BorderSide(
            color: steel.withOpacity(0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),

      // Elevated Button Theme - Minimalist, rectangular
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scarletRed,
          foregroundColor: pureWhite,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Rectangular
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ritualRed,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme - Minimalist, rectangular
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scarletRed,
          side: const BorderSide(
            color: scarletRed,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Rectangular
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // Input Decoration Theme - Minimalist, rectangular
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkGray,

        // Border styles - clean lines, no rounded corners
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(
            color: steel.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(
            color: steel.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            color: scarletRed,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            color: alertYellow,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            color: alertYellow,
            width: 1,
          ),
        ),

        // Text styles
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          color: limestoneGray,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          color: ritualRed,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: coldGray,
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          color: alertYellow,
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: obscureGray,
        selectedItemColor: ritualRed,
        unselectedItemColor: coldGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ritualRed,
        foregroundColor: paleWhite,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: limestoneGray,
        size: 24,
      ),

      // Dialog Theme - Minimalist, rectangular
      dialogTheme: DialogThemeData(
        backgroundColor: darkGray,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(
            color: steel.withOpacity(0.5),
            width: 1,
          ),
        ),
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: pureWhite,
          letterSpacing: 1.0,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: lightGray,
        ),
      ),

      // Snackbar Theme - Minimalist, rectangular
      snackBarTheme: SnackBarThemeData(
        backgroundColor: steel,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 13,
          color: pureWhite,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: industrialGray,
        thickness: 1.6,
        space: 1.6,
      ),

      // Chip Theme - Minimalist, rectangular
      chipTheme: ChipThemeData(
        backgroundColor: steel,
        deleteIconColor: pureWhite,
        disabledColor: darkGray,
        selectedColor: scarletRed,
        secondarySelectedColor: bloodRed,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        secondaryLabelStyle: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: pureWhite,
          letterSpacing: 0.5,
        ),
        brightness: Brightness.dark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // Rectangular
        ),
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: industrialGray,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: coldGray.withOpacity(0.3),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 12,
          color: paleWhite,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ritualRed,
        linearTrackColor: industrialGray,
        circularTrackColor: industrialGray,
      ),

      // Slider Theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: ritualRed,
        inactiveTrackColor: industrialGray,
        thumbColor: paleWhite,
        overlayColor: Color(0x29C12725),
        valueIndicatorColor: ritualRed,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return paleWhite;
          return coldGray;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return ritualRed;
          return industrialGray;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return ritualRed;
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(paleWhite),
        side: const BorderSide(color: coldGray, width: 1.6),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return ritualRed;
          return coldGray;
        }),
      ),
    );
  }
}

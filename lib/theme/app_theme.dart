import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hexatombe Theme - Complete color palette and typography system
/// Based on the Ordem Paranormal: Hexatombe visual identity
class AppTheme {
  // ============================================================================
  // HEXATOMBE COLOR PALETTE
  // ============================================================================

  /// Primary Colors - Core brand identity
  static const Color ritualRed = Color(0xFFC12725);        // Vermelho Ritualístico
  static const Color abyssalBlack = Color(0xFF0E0E0F);     // Preto Abissal
  static const Color obscureGray = Color(0xFF1A1B1F);      // Cinza Obscuro

  /// Secondary Colors - Occult accents
  static const Color chaoticMagenta = Color(0xFF842047);   // Magenta Caótico
  static const Color etherealPurple = Color(0xFF3C235B);   // Roxo Etéreo
  static const Color industrialGray = Color(0xFF2A2D31);   // Cinza Industrial

  /// Neutral Colors - Text and UI elements
  static const Color coldGray = Color(0xFF7A7D81);         // Cinza Frio (secondary text)
  static const Color limestoneGray = Color(0xFFD1D3D6);    // Cinza Calcário (borders)
  static const Color paleWhite = Color(0xFFF2F2F2);        // Branco Pálido (main text)

  /// Accent Colors - Special states and effects
  static const Color alertYellow = Color(0xFFD1A040);      // Amarelo Alerta (damage, warning)
  static const Color mutagenGreen = Color(0xFF468B45);     // Verde Mutagênico (heal, buffs)

  /// Gradient Definitions
  static const LinearGradient ritualGradient = LinearGradient(
    colors: [ritualRed, chaoticMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient abyssGradient = LinearGradient(
    colors: [abyssalBlack, obscureGray],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient occultGradient = LinearGradient(
    colors: [etherealPurple, chaoticMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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

      // Card Theme
      cardTheme: CardThemeData(
        color: obscureGray,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: abyssalBlack.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(
            color: industrialGray,
            width: 1.6,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ritualRed,
          foregroundColor: paleWhite,
          elevation: 2,
          shadowColor: ritualRed.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
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

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ritualRed,
          side: const BorderSide(
            color: ritualRed,
            width: 1.6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: industrialGray,

        // Border styles - using subtle shadows instead of hard borders
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: ritualRed.withOpacity(0.3),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: alertYellow.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: alertYellow.withOpacity(0.3),
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

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: obscureGray,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(
            color: industrialGray,
            width: 1.6,
          ),
        ),
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: paleWhite,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: paleWhite,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: industrialGray,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: paleWhite,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: industrialGray,
        thickness: 1.6,
        space: 1.6,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: industrialGray,
        deleteIconColor: paleWhite,
        disabledColor: obscureGray,
        selectedColor: ritualRed,
        secondarySelectedColor: chaoticMagenta,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: paleWhite,
        ),
        brightness: Brightness.dark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
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

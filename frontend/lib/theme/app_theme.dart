import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium app theme with deep navy/slate dark mode palette
/// Following 8.0 logical pixel spacing system
class AppTheme {
  AppTheme._();

  // === COLOR PALETTE ===
  // Deep navy/slate dark mode colors inspired by Linear/Revolut
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color secondaryNavy = Color(0xFF1E293B);
  static const Color surfaceNavy = Color(0xFF1E1B4B);
  static const Color cardNavy = Color(0xFF334155);
  
  // Accent colors
  static const Color accentPurple = Color(0xFF6366F1);
  static const Color accentFuchsia = Color(0xFFD946EF);
  static const Color accentViolet = Color(0xFFA78BFA);
  
  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Surface colors with opacity
  static const Color surfaceLight = Color(0x1AFFFFFF); // 10% white
  static const Color surfaceMedium = Color(0x26FFFFFF); // 15% white
  static const Color borderSubtle = Color(0x1AFFFFFF); // 10% white for borders

  // === GRADIENTS ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPurple, accentFuchsia],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceNavy, primaryNavy],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  // === SPACING (8px grid) ===
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;

  // === BORDER RADIUS ===
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 32.0;

  // === ANIMATION DURATIONS ===
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // === TEXT THEME ===
  static TextTheme get textTheme => const TextTheme(
    // Display styles - for large, prominent text
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.5,
      height: 1.1,
      color: Colors.white,
    ),
    displayMedium: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
      color: Colors.white,
    ),
    displaySmall: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.2,
      color: Colors.white,
    ),
    
    // Headline styles - for section headers
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.3,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.3,
      color: Colors.white,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
      color: Colors.white,
    ),
    
    // Title styles - for cards and list items
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      color: Colors.white,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      color: Colors.white,
    ),
    
    // Body styles - for regular text content
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.5,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
      color: Colors.white,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.5,
      color: Colors.white70,
    ),
    
    // Label styles - for buttons and captions
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.4,
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      color: Colors.white70,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      color: Colors.white54,
    ),
  );

  // === THEME DATA ===
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: accentFuchsia,
      onPrimary: Colors.white,
      primaryContainer: accentPurple,
      onPrimaryContainer: Colors.white,
      secondary: accentViolet,
      onSecondary: Colors.white,
      secondaryContainer: surfaceNavy,
      onSecondaryContainer: Colors.white,
      tertiary: accentPurple,
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: primaryNavy,
      onSurface: Colors.white,
      surfaceContainerHighest: secondaryNavy,
      onSurfaceVariant: Colors.white70,
      outline: borderSubtle,
      outlineVariant: Color(0x33FFFFFF),
    ),
    
    // Scaffold
    scaffoldBackgroundColor: primaryNavy,
    
    // Text Theme
    textTheme: textTheme,
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceNavy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.headlineSmall,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    
    // Card Theme - using custom containers instead
    cardTheme: CardTheme(
      color: secondaryNavy,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: const BorderSide(color: borderSubtle),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentFuchsia,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentViolet,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing8,
        ),
        textStyle: textTheme.labelMedium,
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        side: const BorderSide(color: accentViolet),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderSubtle, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderSubtle, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: accentPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(color: accentViolet),
      hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white38),
      prefixIconColor: accentViolet,
      suffixIconColor: accentViolet,
      floatingLabelStyle: textTheme.bodySmall?.copyWith(color: accentViolet),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryNavy,
      selectedItemColor: accentFuchsia,
      unselectedItemColor: accentViolet,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    
    // Drawer Theme
    drawerTheme: const DrawerThemeData(
      backgroundColor: surfaceNavy,
    ),
    
    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: secondaryNavy,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXLarge),
      ),
      titleTextStyle: textTheme.headlineMedium,
      contentTextStyle: textTheme.bodyMedium,
    ),
    
    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: secondaryNavy,
      contentTextStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: surfaceLight,
      selectedColor: accentFuchsia.withOpacity(0.3),
      labelStyle: textTheme.labelMedium,
      side: BorderSide(color: accentViolet.withOpacity(0.5)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: borderSubtle,
      thickness: 1,
      space: spacing16,
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: accentViolet,
      size: 24,
    ),
    
    // List Tile Theme
    listTileTheme: ListTileThemeData(
      iconColor: accentViolet,
      textColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
    
    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accentFuchsia,
      linearTrackColor: surfaceLight,
      circularTrackColor: surfaceLight,
    ),
  );

  // === CUSTOM BOX DECORATIONS ===
  
  /// Glass effect container decoration
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: surfaceLight,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(color: borderSubtle),
    boxShadow: const [
      BoxShadow(
        color: Color(0x19000000),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  );

  /// Elevated card decoration with subtle shadow
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(color: borderSubtle),
    boxShadow: const [
      BoxShadow(
        color: Color(0x26000000),
        blurRadius: 32,
        offset: Offset(0, 12),
      ),
      // Inner highlight
      BoxShadow(
        color: Color(0x0CFFFFFF),
        blurRadius: 1,
        offset: Offset(0, 1),
      ),
    ],
  );

  /// Primary gradient button decoration
  static BoxDecoration get gradientButtonDecoration => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: [
      BoxShadow(
        color: accentFuchsia.withOpacity(0.4),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

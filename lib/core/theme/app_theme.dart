import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vpnchik/core/theme/app_theme_mode.dart';
import 'package:vpnchik/core/theme/theme_extensions.dart';

class AppTheme {
  AppTheme(this.mode, this.fontFamily);
  final AppThemeMode mode;
  final String fontFamily;

  // Pastel kawaii palette for vpnchik
  static const Color pastelPink = Color(0xFFF8BBD0);
  static const Color pastelPeach = Color(0xFFFFD1B3);
  static const Color lavender = Color(0xFFD1C4E9);
  static const Color creamyWhite = Color(0xFFFFFAF5);
  static const Color warmBg = Color(0xFFFFF0F3);
  static const Color warmDarkText = Color(0xFF3D2C2E);
  static const Color pastelRose = Color(0xFFE8A0BF);
  static const Color softLilac = Color(0xFFC9B1E0);

  TextStyle? _baseFont([TextStyle? style]) {
    final String font = fontFamily.isNotEmpty ? fontFamily : 'Nunito';
    return GoogleFonts.getFont(font, textStyle: style);
  }

  ThemeData lightTheme(ColorScheme? lightColorScheme) {
    final ColorScheme scheme = lightColorScheme ??
        ColorScheme.fromSeed(
          seedColor: pastelPink,
          primary: pastelPink,
          secondary: pastelPeach,
          tertiary: lavender,
          surface: creamyWhite,
          brightness: Brightness.light,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        surface: creamyWhite,
        primary: pastelPink,
        secondary: pastelPeach,
        tertiary: lavender,
        onPrimary: warmDarkText,
        onSecondary: warmDarkText,
        onTertiary: warmDarkText,
        onSurface: warmDarkText,
      ),
      fontFamily: fontFamily.isNotEmpty ? fontFamily : 'Nunito',
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: _baseFont(),
        displayMedium: _baseFont(),
        displaySmall: _baseFont(),
        headlineLarge: _baseFont(),
        headlineMedium: _baseFont(),
        headlineSmall: _baseFont(),
        titleLarge: _baseFont(),
        titleMedium: _baseFont(),
        titleSmall: _baseFont(),
        bodyLarge: _baseFont(),
        bodyMedium: _baseFont(),
        bodySmall: _baseFont(),
        labelLarge: _baseFont(),
        labelMedium: _baseFont(),
        labelSmall: _baseFont(),
      ),
      scaffoldBackgroundColor: warmBg,
      appBarTheme: AppBarTheme(
        backgroundColor: creamyWhite.withValues(alpha: 0.85),
        foregroundColor: warmDarkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _baseFont(
          const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: warmDarkText,
            letterSpacing: -0.3,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: creamyWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: pastelPink.withValues(alpha: 0.2)),
        ),
        shadowColor: pastelPink.withValues(alpha: 0.15),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: pastelPink,
        foregroundColor: warmDarkText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>{ConnectionButtonTheme.light},
    );
  }

  ThemeData darkTheme(ColorScheme? darkColorScheme) {
    // Return light theme always — no dark mode in vpnchik kawaii edition
    return lightTheme(darkColorScheme);
  }

  /// Boring monochrome theme — white surfaces, grey backgrounds, no pastels.
  static ThemeData monochromeTheme() {
    const Color bgGrey = Color(0xFFF5F5F5);
    const Color darkText = Color(0xFF212121);
    const Color surfaceWhite = Colors.white;
    const Color primaryGrey = Color(0xFF616161);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: bgGrey,
        primary: primaryGrey,
        secondary: Color(0xFF9E9E9E),
        surface: surfaceWhite,
        brightness: Brightness.light,
      ).copyWith(
        surface: surfaceWhite,
        primary: primaryGrey,
        secondary: const Color(0xFF9E9E9E),
        onPrimary: darkText,
        onSecondary: darkText,
        onSurface: darkText,
      ),
      scaffoldBackgroundColor: bgGrey,
      fontFamily: 'Nunito',
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.getFont('Nunito'),
        displayMedium: GoogleFonts.getFont('Nunito'),
        displaySmall: GoogleFonts.getFont('Nunito'),
        headlineLarge: GoogleFonts.getFont('Nunito'),
        headlineMedium: GoogleFonts.getFont('Nunito'),
        headlineSmall: GoogleFonts.getFont('Nunito'),
        titleLarge: GoogleFonts.getFont('Nunito'),
        titleMedium: GoogleFonts.getFont('Nunito'),
        titleSmall: GoogleFonts.getFont('Nunito'),
        bodyLarge: GoogleFonts.getFont('Nunito'),
        bodyMedium: GoogleFonts.getFont('Nunito'),
        bodySmall: GoogleFonts.getFont('Nunito'),
        labelLarge: GoogleFonts.getFont('Nunito'),
        labelMedium: GoogleFonts.getFont('Nunito'),
        labelSmall: GoogleFonts.getFont('Nunito'),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkText,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGrey,
        foregroundColor: surfaceWhite,
      ),
      extensions: const <ThemeExtension<dynamic>>{ConnectionButtonTheme.light},
    );
  }

  CupertinoThemeData cupertinoThemeData(bool sysDark, ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) {
    final bool isDark = switch (mode) {
      AppThemeMode.system => sysDark,
      AppThemeMode.light => false,
      AppThemeMode.dark => false,
      AppThemeMode.black => false,
    };
    final def = CupertinoThemeData(brightness: isDark ? Brightness.dark : Brightness.light);

    final defaultMaterialTheme = isDark ? darkTheme(darkColorScheme) : lightTheme(lightColorScheme);
    return MaterialBasedCupertinoThemeData(
      materialTheme: defaultMaterialTheme.copyWith(
        cupertinoOverrideTheme: def.copyWith(
          textTheme: CupertinoTextThemeData(
            textStyle: def.textTheme.textStyle.copyWith(fontFamily: fontFamily.isNotEmpty ? fontFamily : 'Nunito'),
            actionTextStyle: def.textTheme.actionTextStyle.copyWith(fontFamily: fontFamily.isNotEmpty ? fontFamily : 'Nunito'),
            navActionTextStyle: def.textTheme.navActionTextStyle.copyWith(fontFamily: fontFamily.isNotEmpty ? fontFamily : 'Nunito'),
            navTitleTextStyle: def.textTheme.navTitleTextStyle.copyWith(fontFamily: fontFamily.isNotEmpty ? fontFamily : 'Nunito'),
            navLargeTitleTextStyle: def.textTheme.navLargeTitleTextStyle.copyWith(fontFamily: fontFamily.isNotEmpty ? fontFamily : 'Nunito'),
            pickerTextStyle: def.textTheme.pickerTextStyle.copyWith(fontFamily: fontFamily.isNotEmpty ? fontFamily : 'Nunito'),
            dateTimePickerTextStyle: def.textTheme.dateTimePickerTextStyle.copyWith(fontFamily: fontFamily.isNotEmpty ? fontFamily : 'Nunito'),
            tabLabelTextStyle: def.textTheme.tabLabelTextStyle.copyWith(fontFamily: fontFamily.isNotEmpty ? fontFamily : 'Nunito'),
          ).copyWith(),
          barBackgroundColor: def.barBackgroundColor,
          scaffoldBackgroundColor: def.scaffoldBackgroundColor,
        ),
      ),
    );
  }
}

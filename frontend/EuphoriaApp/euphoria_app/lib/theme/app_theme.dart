import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color netflixRed = Color(0xFFE50914);
  static const Color darkRed = Color(0xFFB20710);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF141414);
  static const Color cardGrey = Color(0xFF1A1A1A);
  static const Color surfaceGrey = Color(0xFF212121);
  static const Color borderGrey = Color(0xFF2A2A2A);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFFE5E5E5);
  static const Color textMuted = Color(0xFF808080);
  static const Color textDim = Color(0xFF535353);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    primaryColor: netflixRed,
    colorScheme: const ColorScheme.dark(
      primary: netflixRed,
      secondary: darkRed,
      surface: darkGrey,
      onPrimary: textWhite,
      onSurface: textWhite,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: textWhite, displayColor: textWhite),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textWhite,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: textWhite),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0A0A0A),
      selectedItemColor: netflixRed,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(color: cardGrey, elevation: 0),
    iconTheme: const IconThemeData(color: textWhite),
    sliderTheme: SliderThemeData(
      activeTrackColor: netflixRed,
      inactiveTrackColor: borderGrey,
      thumbColor: textWhite,
      overlayColor: netflixRed.withOpacity(0.2),
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
    ),
  );
}

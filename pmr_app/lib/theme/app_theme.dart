import 'package:flutter/material.dart';

/// Colors mirrored 1:1 from the original HTML :root CSS variables.
class AppColors {
  static const skyTop = Color(0xFFEAF4FF);
  static const skyMid = Color(0xFFCFE7FF);
  static const skyBot = Color(0xFFA9CFF5);

  static const glass = Color(0x80FFFFFF); // rgba(255,255,255,.5)
  static const glassStrong = Color(0xB8FFFFFF); // rgba(255,255,255,.72)
  static const glassBorder = Color(0xD9FFFFFF); // rgba(255,255,255,.85)

  static const ink = Color(0xFF20344A);
  static const inkSoft = Color(0xFF5A7A93);
  static const accent = Color(0xFF3E8FDE);
  static const accent2 = Color(0xFF7EC4F2);

  static const glow = Color(0xFF66C6FF);
  static const hot = Color(0xFFFF5C5C);
  static const gold = Color(0xFFFFC94D);
  static const green = Color(0xFF3ECF7A);

  static const stageBg = Color(0xFF050912);

  static const goldBadgeStart = Color(0xFFFFE9B3);
  static const goldBadgeEnd = Color(0xFFFFD98A);
  static const goldBadgeText = Color(0xFF8A6A1E);

  static const greenBadgeStart = Color(0xFFCFF5DE);
  static const greenBadgeEnd = Color(0xFFA9EAC4);
  static const greenBadgeText = Color(0xFF2A5C46);

  static const confettiColors = [
    accent,
    accent2,
    gold,
    Color(0xFFFF8FA3),
    green,
  ];

  static const skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyTop, skyMid, skyBot],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, Color(0xFFFFA53E)],
  );
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Segoe UI',
  scaffoldBackgroundColor: AppColors.skyMid,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.light,
  ),
);

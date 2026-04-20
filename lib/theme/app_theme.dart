import 'package:flutter/material.dart';

class AppColors {
  // Pink family (Default theme).
  static const hotPink = Color(0xFFFF2DB2);
  static const magenta = Color(0xFFE4007A);
  static const softPink = Color(0xFFFF7AD9);

  // Accent colors used across dialogs + in-theme text.
  /// Warm orange — used where UI previously used red (destructive
  /// badges, error copy, accents on light dialogs).
  static const orange = Color(0xFFE66A1E);

  /// True deep red — for the Red theme's primary gradient.
  static const red = Color(0xFFC81E1E);

  /// Rich blue — Blue theme primary.
  static const blue = Color(0xFF1E67C8);

  /// Rich green — Green theme primary.
  static const green = Color(0xFF1E8A4C);

  static const white = Colors.white;
}

class AppThemeData {
  final String label;
  final Color primary;
  final Color secondary;
  const AppThemeData({
    required this.label,
    required this.primary,
    required this.secondary,
  });
}

/// Every color theme selectable from Profile → App Preferences.
class AppThemes {
  static const pink = AppThemeData(
    label: 'Default',
    primary: AppColors.magenta,
    secondary: Colors.white,
  );

  static const red = AppThemeData(
    label: 'Red & Black',
    primary: AppColors.red,
    secondary: Colors.white,
  );

  static const purple = AppThemeData(
    label: 'Purple & Gray',
    primary: Color(0xFF6F3A8F),
    secondary: Colors.white,
  );

  static const blue = AppThemeData(
    label: 'Blue',
    primary: AppColors.blue,
    secondary: Colors.white,
  );

  static const green = AppThemeData(
    label: 'Green',
    primary: AppColors.green,
    secondary: Colors.white,
  );

  static const all = <AppThemeData>[pink, red, purple, blue, green];

  static AppThemeData byLabel(String label) {
    return all.firstWhere(
      (t) => t.label == label,
      orElse: () => pink,
    );
  }
}

class AppTheme {
  static final ValueNotifier<AppThemeData> notifier =
      ValueNotifier(AppThemes.pink);

  static Color get primary => notifier.value.primary;
  static Color get secondary => notifier.value.secondary;

  static void setTheme(AppThemeData data) {
    notifier.value = data;
  }
}

class AppGradients {
  static LinearGradient get bg => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTheme.primary, AppTheme.primary],
      );

  static Color _shade(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount) ?? color;
  }

  static RadialGradient get panel => RadialGradient(
        center: const Alignment(-0.2, -0.2),
        radius: 1.2,
        colors: [
          AppTheme.primary,
          _shade(AppTheme.primary, 0.25),
          _shade(AppTheme.primary, 0.45),
        ],
        stops: const [0.0, 0.55, 1.0],
      );
}

/// Accent color to use inside white dialogs. The dialog background is
/// always white, so we need a readable accent that matches the current
/// theme's primary color. For the default (very light secondary) theme
/// we fall back to orange.
Color dialogAccent() {
  final secondary = AppTheme.secondary;
  if (secondary.computeLuminance() > 0.8) {
    return AppColors.orange;
  }
  return secondary;
}

/// Primary text color inside white dialogs.
Color dialogText() {
  final secondary = AppTheme.secondary;
  if (secondary.computeLuminance() > 0.8) {
    return Colors.black87;
  }
  return secondary;
}

class UI {
  static const double radius = 20;
  static const EdgeInsets pagePad = EdgeInsets.symmetric(horizontal: 20);

  static TextStyle title() => TextStyle(
        color: AppTheme.secondary,
        fontWeight: FontWeight.w800,
        fontSize: 22,
        letterSpacing: 0.3,
      );

  static TextStyle subtitle() => TextStyle(
        color: AppTheme.secondary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.2,
      );

  static TextStyle buttonText() => TextStyle(
        color: AppTheme.secondary,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      );

  static TextStyle inputText = TextStyle(color: AppTheme.secondary);

  static InputDecoration input(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.secondary.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );
}

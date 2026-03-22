import 'package:flutter/material.dart';

class AppTheme {
  final bool isDark;
  AppTheme(this.isDark);

  Color get bgColor => isDark ? Colors.black : const Color(0xFFF2F2F7);

  Color get cardColor => isDark ? const Color(0xFF1C1C1E) : Colors.white;

  Color get textColor => isDark ? Colors.white : Colors.black87;
  Color get subTextColor => isDark ? Colors.white38 : Colors.black38;
  Color get hintColor =>
      isDark ? Colors.white10 : Colors.black.withOpacity(0.05);

  Color get itemGray =>
      isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

  Color get setIndicatorColor => const Color(0xFFFFCC00);

  List<BoxShadow> get cardShadow => isDark
      ? []
      : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];

  bool get useLightStatus => isDark;
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'score_logic.dart';

class ModeSwitcher extends StatelessWidget {
  final ScoreController controller;
  final AppTheme theme;
  final bool isDarkMode;

  const ModeSwitcher({
    super.key,
    required this.controller,
    required this.theme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(2), 
      decoration: BoxDecoration(
        color: theme.itemGray, 
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: controller.isDoubles 
                ? Alignment.centerRight 
                : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5, 
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF636366) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isDarkMode 
                      ? [] 
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
              ),
            ),
          ),
          
          Row(
            children: [
              _modeBtn("Singles", !controller.isDoubles, () => controller.switchMode(false)),
              _modeBtn("Doubles", controller.isDoubles, () => controller.switchMode(true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeBtn(String label, bool active, VoidCallback tap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!active) {
            HapticFeedback.selectionClick();
            tap();
          }
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: active 
                  ? theme.textColor 
                  : theme.subTextColor.withOpacity(0.7),
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: -0.2, 
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
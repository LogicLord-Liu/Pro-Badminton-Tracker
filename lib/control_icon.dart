import 'package:flutter/material.dart';
import 'app_theme.dart';

class ControlIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final VoidCallback? onLongPress;
  final Color? color;
  final AppTheme theme;

  const ControlIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.enabled,
    required this.theme,
    this.onLongPress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Opacity(
        opacity: enabled ? 1 : 0.2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color ?? theme.textColor),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color?.withOpacity(0.5) ?? theme.subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
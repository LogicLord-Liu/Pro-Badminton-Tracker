import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'score_logic.dart';
import 'settings_sheet.dart';

class TopBar extends StatelessWidget {
  final ScoreController controller;
  final AppTheme theme;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Color setIndicatorColor;

  const TopBar({
    super.key,
    required this.controller,
    required this.theme,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.setIndicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    // 适配 iOS 状态栏高度的容器
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: NavigationToolbar(
        // --- 左侧：设置 ---
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            showSettingsSheet(context, theme, controller, isDarkMode);
          },
          icon: Icon(
            Icons.settings_outlined, // 使用线条形图标更显精致
            color: theme.subTextColor,
            size: 24,
          ),
        ),

        // --- 中间：当前局数状态 ---
        middle: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            // 微微透明的背景，像 iOS 的状态标签
            color: setIndicatorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            controller.isMatchFinished ? "FINISHED" : "SET ${controller.currentSet}",
            style: TextStyle(
              fontSize: 15, // iOS 标题通常不宜过大，15-17 最佳
              fontWeight: FontWeight.w700,
              color: setIndicatorColor,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // --- 右侧：主题切换 + 历史记录 ---
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 主题切换
            IconButton(
              onPressed: onToggleTheme,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  key: ValueKey(isDarkMode),
                  color: setIndicatorColor,
                  size: 22,
                ),
              ),
            ),
            
            // 历史记录
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  // 稍微延迟以确保点击反馈顺滑
                  Future.delayed(const Duration(milliseconds: 50), () {
                    Scaffold.of(ctx).openEndDrawer();
                  });
                },
                icon: Icon(
                  Icons.history_rounded,
                  color: theme.subTextColor,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
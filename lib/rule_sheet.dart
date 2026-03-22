import 'package:flutter/material.dart';
import 'app_theme.dart';

void showRulesDetail(BuildContext context, AppTheme theme) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    builder: (ctx) => Container(
      height: MediaQuery.of(ctx).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > 10) {
                Navigator.pop(ctx);
              }
            },
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.hintColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "BWF SCORING RULES",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: 16,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  _ruleItem(
                    theme,
                    "21 Points",
                    "A match consists of the best of 3 games of 21 points.",
                    showDivider: true,
                  ),
                  _ruleItem(
                    theme,
                    "Deuce",
                    "At 20-all, the side which gains a 2-point lead first wins that game.",
                    showDivider: true,
                  ),
                  _ruleItem(
                    theme,
                    "30-Point Limit",
                    "At 29-all, the side scoring the 30th point wins that game.",
                    showDivider: true,
                  ),
                  _ruleItem(
                    theme,
                    "Interval",
                    "When the leading score reaches 11 points, players have a 60-second interval.",
                    showDivider: true,
                  ),
                  _ruleItem(
                    theme,
                    "Change Ends",
                    "In the third game, players change ends when a side reaches 11 points.",
                    showDivider: true,
                  ),
                  _ruleItem(
                    theme,
                    "Serving Position",
                    "Even scores (0, 2, 4...) - serve from the right court; Odd scores (1, 3, 5...) - serve from the left court.",
                    showDivider: false,
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "Official regulations by BWF",
                      style: TextStyle(color: theme.subTextColor, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "I UNDERSTAND",
                    style: TextStyle(
                      color: Color(0xFF0A84FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _ruleItem(AppTheme theme, String title, String desc, {bool showDivider = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(
                title,
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  color: theme.subTextColor, 
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
      if (showDivider)
        Divider(
          height: 1,
          color: theme.hintColor.withOpacity(0.3),
          thickness: 0.5,
        ),
    ],
  );
}
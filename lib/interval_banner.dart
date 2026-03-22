import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'score_logic.dart';

class IntervalBanner extends StatelessWidget {
  final ScoreController controller;
  final Color amberColor;

  const IntervalBanner({
    super.key,
    required this.controller,
    this.amberColor = const Color(0xFFFFD60A),
  });

  @override
  Widget build(BuildContext context) {
    bool isInterval = controller.isInterval;
    bool show = isInterval || controller.isMatchFinished;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: show ? 40 : 0,
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: show ? 16 : 0),
      child: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: GestureDetector(
            onTap: isInterval
                ? () {
                    HapticFeedback.mediumImpact();
                    controller.skipInterval();
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: isInterval
                    ? Border.all(color: amberColor.withOpacity(0.3), width: 1)
                    : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.intervalText,
                    style: TextStyle(
                      color: amberColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (isInterval) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.skip_next_rounded, color: amberColor, size: 14),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

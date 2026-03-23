import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'score_logic.dart';
import 'app_theme.dart';

class ScoreCard extends StatefulWidget {
  final bool isA;
  final ScoreController controller;
  final Color color;
  final VoidCallback onNameTap;
  final AppTheme theme;

  const ScoreCard({
    super.key,
    required this.isA,
    required this.controller,
    required this.color,
    required this.onNameTap,
    required this.theme,
  });

  @override
  State<ScoreCard> createState() => _ScoreCardState();
}

class _ScoreCardState extends State<ScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentServer = widget.controller.isAServing == widget.isA;
    int score = widget.isA
        ? widget.controller.currentScoreA
        : widget.controller.currentScoreB;
    int sets = widget.isA ? widget.controller.setsA : widget.controller.setsB;
    bool isWinner =
        widget.controller.isMatchFinished &&
        sets >= widget.controller.winThreshold;
    int pointsToWin = widget.controller.winThreshold;

    bool isServeLeft = isCurrentServer
        ? (widget.isA
              ? widget.controller.isServingLeftA
              : widget.controller.isServingLeftB)
        : false;

    return GestureDetector(
      onTapDown: (_) => _pressController.reverse(),
      onTapUp: (_) {
        _pressController.forward();
        HapticFeedback.mediumImpact();
        widget.controller.updateScore(widget.isA, 1);
      },
      onTapCancel: () => _pressController.forward(),
      child: ScaleTransition(
        scale: _pressController,
        child: Container(
          decoration: BoxDecoration(
            color: widget.theme.cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: widget.theme.cardShadow,
            border: Border.all(
              color: isCurrentServer
                  ? widget.color.withOpacity(0.8)
                  : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                if (isCurrentServer)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.color.withOpacity(0.08),
                            widget.color.withOpacity(0.01),
                          ],
                        ),
                      ),
                    ),
                  ),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: widget.onNameTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCurrentServer
                                ? widget.color.withOpacity(0.15)
                                : widget.theme.hintColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.isA
                                    ? widget.controller.displayNameA
                                    : widget.controller.displayNameB,
                                style: TextStyle(
                                  color: isCurrentServer
                                      ? widget.theme.textColor
                                      : widget.theme.subTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isCurrentServer) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  isServeLeft
                                      ? Icons.arrow_left
                                      : Icons.arrow_right,
                                  size: 16,
                                  color: widget.color,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 150,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: AnimatedScoreText(
                            score: score,
                            style: TextStyle(
                              color: widget.theme.textColor,
                              fontSize: 120,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -6,
                              fontFeatures: const [
                                ui.FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(pointsToWin, (i) {
                          bool isSetWon = i < sets;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isSetWon ? 20 : 12,
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: isSetWon
                                  ? widget.color
                                  : widget.theme.itemGray,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: widget.controller.canModifyScore
                        ? () {
                            HapticFeedback.lightImpact();
                            widget.controller.updateScore(widget.isA, -1);
                          }
                        : null,
                    child: Opacity(
                      opacity: widget.controller.canModifyScore ? 1.0 : 0.5,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.theme.hintColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 18,
                          color: widget.theme.subTextColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),

                if (isWinner)
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.amber.shade600,
                      size: 28,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedScoreText extends StatelessWidget {
  final int score;
  final TextStyle style;

  const AnimatedScoreText({
    super.key,
    required this.score,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation.drive(Tween(begin: 0.8, end: 1.0)),
            child: child,
          ),
        );
      },
      child: Text(
        '$score',
        key: ValueKey<int>(score),
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }
}

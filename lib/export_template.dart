import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'score_logic.dart';
import 'game_state.dart';

class IosExportTemplate extends StatelessWidget {
  final ScoreController controller;
  const IosExportTemplate({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final groups = controller.groupedHistory;
    final bool isWinnerA = controller.setsA > controller.setsB;
    final maxNameLength = _getMaxPlayerNameLength();

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12, width: 0.5),
        borderRadius: BorderRadius.zero,
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MATCH REPORT",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    _formatDateTime(DateTime.now()),
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.3),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.analytics_rounded,
                color: Colors.black12,
                size: 40,
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTeamTotal(
                controller.displayNameA,
                controller.playersA,
                controller.setsA,
                const Color(0xFF007AFF),
                isWinnerA,
                maxNameLength,
              ),
              const Text(
                "VS",
                style: TextStyle(
                  color: Colors.black12,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              _buildTeamTotal(
                controller.displayNameB,
                controller.playersB,
                controller.setsB,
                const Color(0xFFFF3B30),
                !isWinnerA && controller.isMatchFinished,
                maxNameLength,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "SCORE TREND",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black26,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTrendChart(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ...groups.map((g) => _buildSetRow(g)),
          const SizedBox(height: 24),
          Text(
            "CREATED VIA PRO BADMINTON TRACKER",
            style: TextStyle(
              color: Colors.black.withOpacity(0.1),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxPlayerNameLength() {
    final lengthA = controller.playersA.join(" / ").length;
    final lengthB = controller.playersB.join(" / ").length;
    final maxLength = math.max(lengthA, lengthB);
    return math.max(80, math.min(maxLength * 8, 160));
  }

  Widget _buildTeamTotal(
    String name,
    List<String> names,
    int sets,
    Color color,
    bool isWinner,
    double containerWidth,
  ) {
    return Column(
      children: [
        Icon(
          Icons.workspace_premium,
          color: isWinner ? Colors.amber : Colors.transparent,
          size: 24,
        ),
        const SizedBox(height: 4),
        Container(
          width: containerWidth,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: names
                .map(
                  (n) => Text(
                    n.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "$sets",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 64,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$year-$month-$day $hour:$minute";
  }

  Widget _buildTrendChart() {
    return Container(
      height: 100,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(painter: TrendPainter(controller.history)),
    );
  }

  Widget _buildSetRow(SetGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            "SET ${group.setNumber}",
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const Spacer(),
          Text(
            "${group.setScoreA} - ${group.setScoreB}",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class TrendPainter extends CustomPainter {
  final List<ScoreState> history;
  TrendPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;

    double stepX = size.width / (history.length - 1);
    double maxScore = _calculateDynamicMaxScore();

    final fillPaintA = _createFillPaint(const Color(0xFF007AFF), size);
    final fillPaintB = _createFillPaint(const Color(0xFFFF3B30), size);
    final strokePaintA = _createStyledPaint(const Color(0xFF007AFF));
    final strokePaintB = _createStyledPaint(const Color(0xFFFF3B30));

    _drawFilledGradientPath(
      canvas,
      size,
      history.map((e) => e.sA).toList(),
      fillPaintA,
      stepX,
      maxScore,
    );
    _drawFilledGradientPath(
      canvas,
      size,
      history.map((e) => e.sB).toList(),
      fillPaintB,
      stepX,
      maxScore,
    );

    _drawSmoothCatmullRomPath(
      canvas,
      size,
      history.map((e) => e.sA).toList(),
      strokePaintA,
      stepX,
      maxScore,
    );
    _drawSmoothCatmullRomPath(
      canvas,
      size,
      history.map((e) => e.sB).toList(),
      strokePaintB,
      stepX,
      maxScore,
    );
  }

  Paint _createFillPaint(Color color, Size size) {
    return Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.2),
          color.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
  }

  Paint _createStyledPaint(Color color) {
    return Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
      ..isAntiAlias = true;
  }

  void _drawFilledGradientPath(
    Canvas canvas,
    Size size,
    List<int> scores,
    Paint paint,
    double stepX,
    double maxScore,
  ) {
    final path = Path();
    List<Offset> points = [];

    for (int i = 0; i < scores.length; i++) {
      double x = i * stepX;
      double y = size.height - (scores[i] / maxScore * size.height);
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    path.moveTo(points[0].dx, size.height);
    path.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      Offset p0 = i == 0 ? points[0] : points[i - 1];
      Offset p1 = points[i];
      Offset p2 = points[i + 1];
      Offset p3 = i == points.length - 2 ? points[i + 1] : points[i + 2];

      double cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      double cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      double cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      double cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    path.lineTo(points.last.dx, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawSmoothCatmullRomPath(
    Canvas canvas,
    Size size,
    List<int> scores,
    Paint paint,
    double stepX,
    double maxScore,
  ) {
    final path = Path();
    List<Offset> points = [];

    for (int i = 0; i < scores.length; i++) {
      double x = i * stepX;
      double y = size.height - (scores[i] / maxScore * size.height);
      points.add(Offset(x, y));
    }

    if (points.length == 2) {
      path.moveTo(points[0].dx, points[0].dy);
      path.lineTo(points[1].dx, points[1].dy);
      canvas.drawPath(path, paint);
      return;
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      Offset p0 = i == 0 ? points[0] : points[i - 1];
      Offset p1 = points[i];
      Offset p2 = points[i + 1];
      Offset p3 = i == points.length - 2 ? points[i + 1] : points[i + 2];

      double cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      double cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      double cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      double cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    canvas.drawPath(path, paint);
  }

  double _calculateDynamicMaxScore() {
    if (history.isEmpty) return 21.0;

    int maxA = history.map((e) => e.sA).reduce((a, b) => a > b ? a : b);
    int maxB = history.map((e) => e.sB).reduce((a, b) => a > b ? a : b);
    int overallMax = maxA > maxB ? maxA : maxB;

    int roundedMax = ((overallMax + 4) / 5).floor() * 5;
    double dynamicMax = roundedMax.toDouble();
    dynamicMax = dynamicMax < 21 ? 21.0 : dynamicMax;
    dynamicMax = dynamicMax > 30 ? 30.0 : dynamicMax;

    return dynamicMax;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

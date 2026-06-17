
import 'package:flutter/material.dart';
import 'dart:math' as math;

class FocusScoreIndicatorPainter extends CustomPainter {
  final double score;
  final double goal;

  FocusScoreIndicatorPainter({required this.score, required this.goal});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 15.0;

    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final scorePaint = Paint()
      ..shader = const SweepGradient(
        colors: [Colors.orange, Colors.green],
        stops: [0.0, 0.7],
        transform: GradientRotation(math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final goalPaint = Paint()
      ..color = Colors.blue[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw score arc
    double scoreAngle = (score / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      scoreAngle,
      false,
      scorePaint,
    );

    // Draw goal marker
    double goalAngle = (goal / 100) * 2 * math.pi;
    final goalMarkerX = center.dx + (radius) * math.cos(goalAngle - math.pi / 2);
    final goalMarkerY = center.dy + (radius) * math.sin(goalAngle - math.pi / 2);
    canvas.drawCircle(Offset(goalMarkerX, goalMarkerY), 5, goalPaint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


import 'package:flutter/material.dart';
import 'dart:math' as math;

class PlantWidget extends StatelessWidget {
  final int leaves;

  const PlantWidget({super.key, required this.leaves});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(150, 200),
      painter: _PlantPainter(leaves: leaves),
    );
  }
}

class _PlantPainter extends CustomPainter {
  final int leaves;

  _PlantPainter({required this.leaves});

  @override
  void paint(Canvas canvas, Size size) {
    final potPaint = Paint()..color = Colors.brown[400]!;
    final stemPaint = Paint()
      ..color = Colors.green[800]!
      ..strokeWidth = 4;
    final leafPaint = Paint()..color = Colors.green[600]!;

    // Draw pot
    final potPath = Path();
    potPath.moveTo(size.width * 0.2, size.height);
    potPath.lineTo(size.width * 0.8, size.height);
    potPath.lineTo(size.width * 0.7, size.height * 0.8);
    potPath.lineTo(size.width * 0.3, size.height * 0.8);
    potPath.close();
    canvas.drawPath(potPath, potPaint);

    // Draw stem
    final stemHeight = size.height * 0.7 * (leaves / 10).clamp(0.1, 1.0);
    canvas.drawLine(Offset(size.width / 2, size.height * 0.8), Offset(size.width / 2, size.height * 0.8 - stemHeight), stemPaint);

    // Draw leaves
    for (int i = 0; i < leaves; i++) {
      final leafHeight = (size.height * 0.8 - stemHeight) + (stemHeight * (i / leaves));
      final leafSide = (i % 2 == 0) ? 1 : -1;
      final leafControlX = size.width / 2 + leafSide * (20 + 10 * (i % 3));
      final leafControlY = leafHeight - 10;
      final leafEndX = size.width / 2 + leafSide * (5 + 5 * (i % 2));
      final leafEndY = leafHeight - 25;

      final leafPath = Path();
      leafPath.moveTo(size.width / 2, leafHeight);
      leafPath.quadraticBezierTo(leafControlX, leafControlY, leafEndX, leafEndY);
      leafPath.quadraticBezierTo(leafControlX, leafControlY + 5, size.width / 2, leafHeight);
      canvas.drawPath(leafPath, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

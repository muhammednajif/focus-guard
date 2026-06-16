import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class FidgetSpinnerScreen extends StatefulWidget {
  const FidgetSpinnerScreen({super.key});

  @override
  _FidgetSpinnerScreenState createState() => _FidgetSpinnerScreenState();
}

class _FidgetSpinnerScreenState extends State<FidgetSpinnerScreen> {
  double _rotation = 0.0;
  double _velocity = 0.0;
  Offset? _lastPanPosition;
  Timer? _physicsTimer;

  @override
  void initState() {
    super.initState();
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), _update);
  }

  void _update(Timer timer) {
    if (_velocity.abs() < 0.001) return;

    setState(() {
      _rotation += _velocity;
      _velocity *= 0.98; // Friction factor
      if (_velocity.abs() < 0.001) {
        _velocity = 0.0;
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    _lastPanPosition = details.localPosition;
    setState(() {
      _velocity = 0; // Stop the spinner when user touches it
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final position = details.localPosition;
    if (_lastPanPosition != null) {
      // Calculate the angle change from the center of the screen
      final center = Offset(context.size!.width / 2, context.size!.height / 2);
      final prevAngle = atan2(_lastPanPosition!.dy - center.dy, _lastPanPosition!.dx - center.dx);
      final currentAngle = atan2(position.dy - center.dy, position.dx - center.dx);
      final angleDelta = currentAngle - prevAngle;

      setState(() {
        _rotation += angleDelta;
        _velocity = angleDelta * 2; // Add some extra velocity for a better feel
      });
    }
    _lastPanPosition = position;
  }

  void _onPanEnd(DragEndDetails details) {
    _lastPanPosition = null;
    // Give it a final flick based on the velocity of the gesture
    final flickVelocity = details.velocity.pixelsPerSecond.dx.abs() + details.velocity.pixelsPerSecond.dy.abs();
    setState(() {
      _velocity += (flickVelocity / 1000) * (details.velocity.pixelsPerSecond.dx > 0 ? 1 : -1);
    });
  }

  @override
  void dispose() {
    _physicsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text("Take a Moment"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform.rotate(
            angle: _rotation,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: FidgetSpinnerPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

class FidgetSpinnerPainter extends CustomPainter {
  final Paint spinnerPaint = Paint()..color = Colors.cyanAccent;
  final Paint bearingPaint = Paint()..color = Colors.grey.shade400;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the three arms
    for (int i = 0; i < 3; i++) {
      final angle = (2 * pi / 3) * i;
      final armCenter = Offset(
        center.dx + (radius * 0.6) * cos(angle),
        center.dy + (radius * 0.6) * sin(angle),
      );
      canvas.drawCircle(armCenter, radius * 0.35, spinnerPaint);
    }

    // Draw the central bearing
    canvas.drawCircle(center, radius * 0.25, bearingPaint);
    canvas.drawCircle(center, radius * 0.15, spinnerPaint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

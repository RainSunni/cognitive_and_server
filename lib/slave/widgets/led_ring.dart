import 'package:flutter/material.dart';
import 'dart:math';

class LedRing extends StatelessWidget {
  final List<bool> leds;
  final double radius;
  final double ledSize;
  final Color activeColor;
  final Color inactiveColor;

  const LedRing({
    Key? key,
    required this.leds,
    this.radius = 50.0,
    this.ledSize = 20.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2 + ledSize,
      height: radius * 2 + ledSize,
      child: CustomPaint(
        painter: _LedRingPainter(
          leds: leds,
          radius: radius,
          ledSize: ledSize,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
      ),
    );
  }
}

class _LedRingPainter extends CustomPainter {
  final List<bool> leds;
  final double radius;
  final double ledSize;
  final Color activeColor;
  final Color inactiveColor;

  _LedRingPainter({
    required this.leds,
    required this.radius,
    required this.ledSize,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < leds.length; i++) {
      final angle = i * (2 * pi / leds.length);
      final position = center + Offset(
        radius * cos(angle),
        radius * sin(angle),
      );

      final paint = Paint()
        ..color = leds[i] ? activeColor : inactiveColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position, ledSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
import 'dart:math';

import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -50,
      child: Transform.rotate(
        angle: pi-0.5,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.5,
          child: CustomPaint(
            painter: BackgroundPainter(),
          ),
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.purple;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.8, size.width, size.height * 0.7);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class RulerPainter extends CustomPainter {
  final String unit;
  final int dpi;
  final double width;
  final double height;
  RulerPainter({
    required this.unit,
    required this.dpi,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1;
    double pxPerUnit;
    if (unit == 'cm') {
      pxPerUnit = size.width / width;
    } else if (unit == 'inch') {
      pxPerUnit = size.width / width;
    } else if (unit == 'px') {
      pxPerUnit = size.width / width;
    } else {
      pxPerUnit = 1;
    }
    for (int i = 0; i <= width; i++) {
      double x = i * pxPerUnit;
      canvas.drawLine(Offset(x, 0), Offset(x, 10), paint);
      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(fontSize: 8, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(x + 2, 0));
    }
    for (int i = 0; i <= height; i++) {
      double y = i * (size.height / height);
      canvas.drawLine(Offset(0, y), Offset(10, y), paint);
      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(fontSize: 8, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y + 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

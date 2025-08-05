import 'package:flutter/material.dart';

class PlusControl extends StatelessWidget {
  final Color backgroundColor;
  const PlusControl({super.key, required this.backgroundColor});
  @override
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    final plusColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return SizedBox(
      width: 28,
      height: 28,
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          child: CustomPaint(painter: _PlusPainter(plusColor)),
        ),
      ),
    );
  }
}

class _PlusPainter extends CustomPainter {
  final Color plusColor;
  _PlusPainter(this.plusColor);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = plusColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    canvas.drawLine(
      Offset(centerX, centerY - size.height / 2 + 4),
      Offset(centerX, centerY + size.height / 2 - 4),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - size.width / 2 + 4, centerY),
      Offset(centerX + size.width / 2 - 4, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

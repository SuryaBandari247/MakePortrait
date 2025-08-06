import 'package:flutter/material.dart';
import 'dart:math' as math;

class CelebrationPopper extends StatefulWidget {
  final VoidCallback onDone;
  const CelebrationPopper({super.key, required this.onDone});

  @override
  State<CelebrationPopper> createState() => _CelebrationPopperState();
}

class _CelebrationPopperState extends State<CelebrationPopper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    Future.delayed(const Duration(milliseconds: 1400), () {
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Popper burst
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(200, 200),
                  painter: _PopperPainter(_controller.value),
                );
              },
            ),
            // Text
            Opacity(
              opacity: _controller.value > 0.5 ? 1.0 : 0.0,
              child: const Text(
                '🎉 Saved! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black26,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopperPainter extends CustomPainter {
  final double progress;
  _PopperPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final colors = [
      Colors.pink,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.yellow,
      Colors.red,
      Colors.teal,
    ];
    final count = colors.length;
    final maxLen = 80.0 * progress;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi;
      final p = Offset(
        center.dx + maxLen * math.cos(angle),
        center.dy + maxLen * math.sin(angle),
      );
      final paint = Paint()
        ..color = colors[i].withOpacity(1 - (progress * 0.7))
        ..strokeWidth = 8 - 6 * progress
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center, p, paint);
    }
  }

  @override
  bool shouldRepaint(_PopperPainter oldDelegate) => true;
}

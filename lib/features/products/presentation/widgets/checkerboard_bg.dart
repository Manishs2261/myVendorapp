import 'package:flutter/material.dart';

class CheckerboardBackground extends StatelessWidget {
  final Widget child;
  final double tileSize;

  const CheckerboardBackground({
    super.key,
    required this.child,
    this.tileSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerboardPainter(tileSize: tileSize),
      child: child,
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  final double tileSize;
  _CheckerboardPainter({required this.tileSize});

  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()..color = const Color(0xFFE0E0E0);
    final darkPaint = Paint()..color = const Color(0xFFBDBDBD);

    final cols = (size.width / tileSize).ceil();
    final rows = (size.height / tileSize).ceil();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final paint = (r + c).isEven ? lightPaint : darkPaint;
        canvas.drawRect(
          Rect.fromLTWH(c * tileSize, r * tileSize, tileSize, tileSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerboardPainter old) => old.tileSize != tileSize;
}

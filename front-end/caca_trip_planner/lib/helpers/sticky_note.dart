import 'dart:math';

import 'package:flutter/material.dart';

class StickyNote extends StatelessWidget {
  /// This makes a realistic sticky note in Flutter. Credit: https://www.flutterclutter.dev/flutter/tutorials/create-a-sticky-note-in-flutter/2020/1018/
  /// Always wrap this in a Container! Example:
  /// ```dart
  /// Container(
  ///   color: Colors.white,
  ///   child: Center(
  ///     child: SizedBox(
  ///       width: 300,
  ///       height: 300,
  ///       child: Container(
  ///         color: Colors.white,
  ///         child: StickyNote(),
  ///       ),
  ///     ),
  ///   ),
  /// )
  /// ```
  const StickyNote({
    required this.child,
    this.color = const Color(0xffffff00),
    Key? key,
  }) : super(key: key);

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.01 * pi,
      child: CustomPaint(
          painter: StickyNotePainter(color: color),
          child: Center(child: child)),
    );
  }
}

class StickyNotePainter extends CustomPainter {
  StickyNotePainter({required this.color});

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    _drawShadow(size, canvas);
    Paint gradientPaint = _createGradientPaint(size);
    _drawNote(size, canvas, gradientPaint);
  }

  void _drawNote(Size size, Canvas canvas, Paint gradientPaint) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);

    double foldAmount = 0.12;
    path.lineTo(size.width * 3 / 4, size.height);

    path.quadraticBezierTo(size.width * foldAmount * 2, size.height,
        size.width * foldAmount, size.height - (size.height * foldAmount));
    path.quadraticBezierTo(
        0, size.height - (size.height * foldAmount * 1.5), 0, size.height / 4);
    path.lineTo(0, 0);

    canvas.drawPath(path, gradientPaint);
  }

  Paint _createGradientPaint(Size size) {
    Paint paint = Paint();

    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    RadialGradient gradient = RadialGradient(
        colors: [brighten(color), color],
        radius: 1.0,
        stops: const [0.5, 1.0],
        center: Alignment.bottomLeft);
    paint.shader = gradient.createShader(rect);
    return paint;
  }

  void _drawShadow(Size size, Canvas canvas) {
    Rect rect = Rect.fromLTWH(
      size.height * 0.04,
      size.width * 0.04,
      size.width * 0.92,
      size.height * 0.92,
    );
    // Rect rect = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    Path path = Path();
    path.addRect(rect);
    canvas.drawShadow(path, Colors.black.withOpacity(0.7), 12.0, true);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

Color brighten(Color c, [int percent = 30]) {
  var p = percent / 100;
  return Color.fromARGB(
      c.alpha,
      c.red + ((255 - c.red) * p).round(),
      c.green + ((255 - c.green) * p).round(),
      c.blue + ((255 - c.blue) * p).round());
}

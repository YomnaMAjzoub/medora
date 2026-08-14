
import 'package:flutter/material.dart';


class NavBarPainter extends CustomPainter {
  final double fabRadius;
  final Color fillColor;
  final Color shadowColor;
  final Color borderColor;

  NavBarPainter({
    this.fabRadius = 32,
    required this.fillColor,
    required this.shadowColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();

    final centerX = size.width / 2;

   
    final notchStart = centerX - fabRadius - 12;

    
    final notchEnd = centerX + fabRadius + 12;

    path.moveTo(0, 0);

    
    path.lineTo(notchStart, 0);

   
    path.quadraticBezierTo(notchStart + 6, 0, notchStart + 12, 12);

   
    path.arcToPoint(
      Offset(notchEnd - 12, 12),
      radius: Radius.circular(fabRadius + 4),
      clockwise: false,
    );

   
    path.quadraticBezierTo(notchEnd - 6, 0, notchEnd, 0);

    
    path.lineTo(size.width, 0);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();

    
    canvas.drawShadow(path, shadowColor, 12, false);

    
    canvas.drawPath(path, paint);

    
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
      oldDelegate is! NavBarPainter ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.shadowColor != shadowColor ||
      oldDelegate.borderColor != borderColor;
}

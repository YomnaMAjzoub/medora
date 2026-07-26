
import 'package:flutter/material.dart';
import 'package:medora_git/core/const/app_colors.dart';


class NavBarPainter extends CustomPainter {
  final double fabRadius;

  NavBarPainter({this.fabRadius = 32});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.black.withValues(alpha: .18)
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

    
    canvas.drawShadow(path, AppColors.black, 12, false);

    
    canvas.drawPath(path, paint);

    
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class DamagePainter extends CustomPainter {
  final double normX; 
  final double normY;

  DamagePainter({required this.normX, required this.normY});

  @override
  void paint(Canvas canvas, Size size) {
    bool isPothole = normX > 0.5;

    Color alertColor = isPothole ? Colors.redAccent : Colors.orangeAccent;
    String labelText = isPothole ? " [D40] POTHOLE " : " [D00] CRACK ";

    final paint = Paint()
      ..color = alertColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    double boxSize = size.width * 0.4; 
    double left = normX * (size.width - boxSize);
    double top = normY * (size.height - boxSize);

    final rect = Rect.fromLTWH(left, top, boxSize, boxSize);
    canvas.drawRect(rect, paint);

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      backgroundColor: alertColor,
      shadows: const [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black54,
          offset: Offset(1.0, 1.0),
        ),
      ],
    );

    final textSpan = TextSpan(
      text: labelText,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    
    double textY = top - 20;
    if (textY < 0) textY = top + boxSize + 5; 

    textPainter.paint(canvas, Offset(left, textY));
  }

  @override
  bool shouldRepaint(covariant DamagePainter oldDelegate) {
    return true; 
  }
}

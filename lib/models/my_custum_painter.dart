import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:skribbl/models/touch_points.dart';

class MyCustumPainter extends CustomPainter {
  MyCustumPainter({required this.pointsList});
  List<TouchPoints> pointsList;
  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(
          pointsList[i].points,
          pointsList[i + 1].points,
          pointsList[i].paint,
        );
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(
          Offset(pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1),
        );

        canvas.drawPoints(
          ui.PointMode.points,
          offsetPoints,
          pointsList[i].paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

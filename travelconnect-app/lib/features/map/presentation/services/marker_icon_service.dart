import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../questions/domain/entities/question.dart';

class MarkerIconService {
  static BitmapDescriptor? _defaultIcon;
  static BitmapDescriptor? _urgentIcon;
  static final Map<int, BitmapDescriptor> _clusterIconCache = {};

  static Future<void> loadIcons() async {
    _defaultIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    );
    _urgentIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueOrange,
    );
  }

  static BitmapDescriptor getIcon(Question question) {
    return question.needsAnswer
        ? (_urgentIcon ?? BitmapDescriptor.defaultMarker)
        : (_defaultIcon ?? BitmapDescriptor.defaultMarker);
  }

  static Future<BitmapDescriptor> getClusterIcon(int count) async {
    if (_clusterIconCache.containsKey(count)) {
      return _clusterIconCache[count]!;
    }

    final icon = await _generateClusterIcon(count);
    _clusterIconCache[count] = icon;
    return icon;
  }

  static Future<BitmapDescriptor> _generateClusterIcon(int count) async {
    final size = 150.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Choose color based on cluster size
    final Color color;
    if (count <= 10) {
      color = const Color(0xFF2196F3); // Blue
    } else if (count <= 50) {
      color = const Color(0xFFFF9800); // Orange
    } else {
      color = const Color(0xFFF44336); // Red
    }

    // Draw outer circle (shadow)
    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, shadowPaint);

    // Draw main circle
    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 10, mainPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(
        Offset(size / 2, size / 2), size / 2 - 10, borderPaint);

    // Draw count text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: count > 99 ? '99+' : '$count',
        style: const TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size / 2 - textPainter.width / 2,
        size / 2 - textPainter.height / 2,
      ),
    );

    final image = await recorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }

  static void clearCache() {
    _clusterIconCache.clear();
  }
}

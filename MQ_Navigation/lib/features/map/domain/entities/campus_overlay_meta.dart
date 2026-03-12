import 'package:flutter/foundation.dart';

@immutable
class CampusOverlayMeta {
  const CampusOverlayMeta({
    required this.imageAsset,
    required this.width,
    required this.height,
    required this.pixelOffsetX,
    required this.gpsNorth,
    required this.gpsSouth,
    required this.gpsEast,
    required this.gpsWest,
    required this.initialZoom,
    required this.minZoom,
    required this.maxZoom,
  });

  final String imageAsset;
  final double width;
  final double height;
  final double pixelOffsetX;
  final double gpsNorth;
  final double gpsSouth;
  final double gpsEast;
  final double gpsWest;
  final double initialZoom;
  final double minZoom;
  final double maxZoom;

  factory CampusOverlayMeta.fromJson(Map<String, dynamic> json) {
    final gpsBounds = json['gpsBounds'] as Map<String, dynamic>? ?? const {};
    return CampusOverlayMeta(
      imageAsset: json['imageAsset'] as String,
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      pixelOffsetX: (json['pixelOffsetX'] as num?)?.toDouble() ?? 0,
      gpsNorth: (gpsBounds['north'] as num).toDouble(),
      gpsSouth: (gpsBounds['south'] as num).toDouble(),
      gpsEast: (gpsBounds['east'] as num).toDouble(),
      gpsWest: (gpsBounds['west'] as num).toDouble(),
      initialZoom: (json['initialZoom'] as num?)?.toDouble() ?? 0,
      minZoom: (json['minZoom'] as num?)?.toDouble() ?? -2,
      maxZoom: (json['maxZoom'] as num?)?.toDouble() ?? 2,
    );
  }
}

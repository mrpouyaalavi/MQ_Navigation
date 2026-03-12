import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:mq_navigation/features/map/domain/entities/campus_overlay_meta.dart';
import 'package:mq_navigation/features/map/domain/entities/campus_point.dart';
import 'package:mq_navigation/features/map/domain/services/campus_projection.dart';

class CampusProjectionImpl implements CampusProjection {
  const CampusProjectionImpl(this.meta);

  @override
  final CampusOverlayMeta meta;

  @override
  CampusPoint gpsToPixel({
    required double latitude,
    required double longitude,
  }) {
    final xNorm = (longitude - meta.gpsWest) / (meta.gpsEast - meta.gpsWest);
    final yNorm = (meta.gpsNorth - latitude) / (meta.gpsNorth - meta.gpsSouth);

    return CampusPoint(
      x: (xNorm * meta.width).clamp(0, meta.width),
      y: (yNorm * meta.height).clamp(0, meta.height),
    );
  }

  @override
  LatLng pixelToMapPoint(CampusPoint point) {
    final adjustedX = point.x + meta.pixelOffsetX;
    return LatLng(meta.height - point.y, adjustedX);
  }

  @override
  CampusPoint mapPointToPixel(LatLng point) {
    return CampusPoint(
      x: math.max(0, point.longitude - meta.pixelOffsetX),
      y: math.max(0, meta.height - point.latitude),
    );
  }
}

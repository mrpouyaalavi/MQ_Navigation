import 'package:syllabus_sync/features/map/domain/entities/building.dart';
import 'package:syllabus_sync/features/map/domain/entities/route_leg.dart';

abstract interface class RoutingService {
  Future<MapRoute> getRoute({
    required LocationSample origin,
    required Building destination,
    required TravelMode travelMode,
  });
}

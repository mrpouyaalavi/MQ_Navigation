import 'package:flutter/foundation.dart';
import 'package:mq_navigation/features/map/domain/entities/campus_point.dart';

/// A campus building with its metadata and GPS coordinates.
@immutable
class Building {
  const Building({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.address,
    this.category = BuildingCategory.other,
    this.latitude,
    this.longitude,
    this.entranceLatitude,
    this.entranceLongitude,
    this.googlePlaceId,
    this.levels,
    this.wheelchair = false,
    this.tags = const [],
    this.aliases = const [],
    this.searchTokens = const [],
    this.gridRef,
    this.campusX,
    this.campusY,
    this.facultyGroup,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final String? address;
  final BuildingCategory category;
  final double? latitude;
  final double? longitude;
  final double? entranceLatitude;
  final double? entranceLongitude;
  final String? googlePlaceId;
  final int? levels;
  final bool wheelchair;
  final List<String> tags;
  final List<String> aliases;
  final List<String> searchTokens;
  final String? gridRef;
  final double? campusX;
  final double? campusY;

  /// Which of the four MQ faculty groups this building belongs to,
  /// if any. Drives the **Faculty** category two-level drill-down on
  /// the map: top level shows the four [FacultyGroup] cards, second
  /// level shows only buildings whose `facultyGroup == selected`.
  ///
  /// `null` means the building is not assigned to a faculty group —
  /// it can still be tagged `faculty` for legacy search tokens, but
  /// it won't appear under any specific drill-down branch.
  final FacultyGroup? facultyGroup;

  factory Building.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final entrance = json['entranceLocation'] as Map<String, dynamic>?;
    final campusLocation = json['campusLocation'] as Map<String, dynamic>?;
    final id = json['id'] as String;

    return Building(
      id: id,
      code: (json['code'] as String?) ?? id,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      category: BuildingCategory.fromString(
        json['category'] as String? ?? 'other',
      ),
      latitude:
          (json['latitude'] as num?)?.toDouble() ??
          (location?['lat'] as num?)?.toDouble(),
      longitude:
          (json['longitude'] as num?)?.toDouble() ??
          (location?['lng'] as num?)?.toDouble(),
      entranceLatitude:
          (json['entranceLatitude'] as num?)?.toDouble() ??
          (entrance?['lat'] as num?)?.toDouble(),
      entranceLongitude:
          (json['entranceLongitude'] as num?)?.toDouble() ??
          (entrance?['lng'] as num?)?.toDouble(),
      googlePlaceId: json['googlePlaceId'] as String?,
      levels: (json['levels'] as num?)?.toInt(),
      wheelchair: json['wheelchair'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      aliases: (json['aliases'] as List<dynamic>?)?.cast<String>() ?? [],
      searchTokens:
          (json['searchTokens'] as List<dynamic>?)?.cast<String>() ?? [],
      gridRef: json['gridRef'] as String?,
      campusX:
          (campusLocation?['x'] as num?)?.toDouble() ??
          (json['campusX'] as num?)?.toDouble(),
      campusY:
          (campusLocation?['y'] as num?)?.toDouble() ??
          (json['campusY'] as num?)?.toDouble(),
      facultyGroup: FacultyGroup.fromJson(json['facultyGroup'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'description': description,
    'address': address,
    'category': category.name,
    'latitude': latitude,
    'longitude': longitude,
    'entranceLatitude': entranceLatitude,
    'entranceLongitude': entranceLongitude,
    'location': latitude != null ? {'lat': latitude, 'lng': longitude} : null,
    'entranceLocation': entranceLatitude != null
        ? {'lat': entranceLatitude, 'lng': entranceLongitude}
        : null,
    'googlePlaceId': googlePlaceId,
    'levels': levels,
    'wheelchair': wheelchair,
    'tags': tags,
    'aliases': aliases,
    'searchTokens': searchTokens,
    'gridRef': gridRef,
    'campusX': campusX,
    'campusY': campusY,
    'campusLocation': hasCampusCoordinates
        ? {'x': campusX, 'y': campusY}
        : null,
    'facultyGroup': facultyGroup?.id,
  };

  /// Best coordinate for routing: entrance if available, otherwise building center.
  double? get routingLatitude => entranceLatitude ?? latitude;
  double? get routingLongitude => entranceLongitude ?? longitude;
  bool get hasGeographicCoordinates => latitude != null && longitude != null;
  bool get hasCampusCoordinates => campusX != null && campusY != null;
  CampusPoint? get campusPoint =>
      hasCampusCoordinates ? CampusPoint(x: campusX!, y: campusY!) : null;

  bool get isHighTraffic {
    return const <String>{
      'LIB',
      '18WW',
      '1CC',
      'MUSE',
      '14SCO',
      '12WW',
    }.contains(id.toUpperCase());
  }

  /// Whether this building matches a search query.
  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return id.toLowerCase().contains(q) ||
        code.toLowerCase().contains(q) ||
        name.toLowerCase().contains(q) ||
        category.name.toLowerCase().contains(q) ||
        (description?.toLowerCase().contains(q) ?? false) ||
        (address?.toLowerCase().contains(q) ?? false) ||
        aliases.any((a) => a.toLowerCase().contains(q)) ||
        searchTokens.any((token) => token.toLowerCase().contains(q)) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Building && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Building($id, $name)';
}

enum BuildingCategory {
  academic,
  services,
  health,
  food,
  sports,
  venue,
  research,
  residential,
  parking,
  transport,
  smoking,
  other;

  static BuildingCategory fromString(String value) {
    return BuildingCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BuildingCategory.other,
    );
  }
}

/// The four top-level Macquarie University faculty groups used by
/// the **Faculty** category browse drill-down. The order here is the
/// canonical display order on the first-level faculty list.
///
/// The string [id] is the on-disk JSON identifier in
/// `assets/data/buildings.json`. **Do not rename** these without also
/// migrating the asset and bumping the building registry cache key.
enum FacultyGroup {
  arts(
    id: 'arts',
    label: 'Faculty of Arts',
    description: 'Humanities, Law, Education, MMCCS',
    icon: '\u{1F3DB}',
  ),
  business(
    id: 'business',
    label: 'Macquarie Business School',
    description: 'Business, Economics, Marketing',
    icon: '\u{1F4BC}',
  ),
  mhhs(
    id: 'mhhs',
    label: 'Faculty of Medicine, Health and Human Sciences',
    description: 'Health Sciences, Psychology, Clinical',
    icon: '\u{2695}',
  ),
  scienceEngineering(
    id: 'science_engineering',
    label: 'Faculty of Science and Engineering',
    description: 'Sciences, Engineering, Computing',
    icon: '\u{1F52C}',
  );

  const FacultyGroup({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String id;
  final String label;
  final String description;
  final String icon;

  static FacultyGroup? fromJson(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final group in FacultyGroup.values) {
      if (group.id == value) return group;
    }
    return null;
  }
}

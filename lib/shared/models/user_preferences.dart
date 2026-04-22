import 'package:flutter/material.dart';
import 'package:mq_navigation/features/map/domain/entities/map_renderer_type.dart';
import 'package:mq_navigation/features/map/domain/entities/route_leg.dart';

/// Immutable local data model representing a user's app-wide preferences.
///
/// This object is persisted in secure storage and read during app startup
/// to configure the root theme and localization delegates.
@immutable
class UserPreferences {
  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.localeCode,
    this.notificationsEnabled = true,
    this.defaultRenderer = MapRendererType.campus,
    this.defaultTravelMode = TravelMode.walk,
    this.lowDataMode = false,
    this.reducedMotion = false,
  });

  final ThemeMode themeMode;
  final String? localeCode;
  final bool notificationsEnabled;
  final MapRendererType defaultRenderer;
  final TravelMode defaultTravelMode;
  final bool lowDataMode;
  final bool reducedMotion;

  Locale? get locale => localeCode == null ? null : Locale(localeCode!);

  UserPreferences copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    bool clearLocale = false,
    bool? notificationsEnabled,
    MapRendererType? defaultRenderer,
    TravelMode? defaultTravelMode,
    bool? lowDataMode,
    bool? reducedMotion,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      localeCode: clearLocale ? null : localeCode ?? this.localeCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultRenderer: defaultRenderer ?? this.defaultRenderer,
      defaultTravelMode: defaultTravelMode ?? this.defaultTravelMode,
      lowDataMode: lowDataMode ?? this.lowDataMode,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          localeCode == other.localeCode &&
          notificationsEnabled == other.notificationsEnabled &&
          defaultRenderer == other.defaultRenderer &&
          defaultTravelMode == other.defaultTravelMode &&
          lowDataMode == other.lowDataMode &&
          reducedMotion == other.reducedMotion;

  @override
  int get hashCode => Object.hash(
    themeMode,
    localeCode,
    notificationsEnabled,
    defaultRenderer,
    defaultTravelMode,
    lowDataMode,
    reducedMotion,
  );
}

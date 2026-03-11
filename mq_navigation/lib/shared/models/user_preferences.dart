import 'package:flutter/material.dart';

@immutable
class UserPreferences {
  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.localeCode,
    this.notificationsEnabled = true,
    this.emailNotifications = true,
  });

  final ThemeMode themeMode;
  final String? localeCode;
  final bool notificationsEnabled;
  final bool emailNotifications;

  Locale? get locale => localeCode == null ? null : Locale(localeCode!);

  UserPreferences copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    bool clearLocale = false,
    bool? notificationsEnabled,
    bool? emailNotifications,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      localeCode: clearLocale ? null : localeCode ?? this.localeCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
    );
  }
}

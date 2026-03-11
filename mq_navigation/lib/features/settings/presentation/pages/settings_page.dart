import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_navigation/app/l10n/generated/app_localizations.dart';
import 'package:mq_navigation/app/theme/mq_colors.dart';
import 'package:mq_navigation/app/theme/mq_spacing.dart';
import 'package:mq_navigation/features/settings/presentation/controllers/settings_controller.dart';
import 'package:mq_navigation/shared/widgets/mq_app_bar.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: MqAppBar(title: l10n.settings),
      body: settingsState.when(
        data: (preferences) {
          return ListView(
            padding: const EdgeInsets.all(MqSpacing.space4),
            children: [
              _SettingsSection(
                title: l10n.settings_general,
                child: Column(
                  children: [
                    _DropdownListTile<ThemeMode>(
                      icon: Icons.dark_mode_outlined,
                      title: l10n.appearance,
                      value: preferences.themeMode,
                      itemLabel: (value) => switch (value) {
                        ThemeMode.system => l10n.system,
                        ThemeMode.light  => l10n.light,
                        ThemeMode.dark   => l10n.dark,
                      },
                      items: ThemeMode.values,
                      onChanged: (value) => ref
                          .read(settingsControllerProvider.notifier)
                          .updateThemeMode(value),
                    ),
                    const Divider(height: 1),
                    _DropdownListTile<String?>(
                      icon: Icons.language_outlined,
                      title: l10n.language,
                      value: preferences.localeCode,
                      itemLabel: (value) => _languageLabel(value, l10n),
                      items: const [
                        null, 'en', 'ar', 'bn', 'cs', 'da', 'de', 'el',
                        'es', 'fa', 'fi', 'fr', 'he', 'hi', 'hu', 'id',
                        'it', 'ja', 'ko', 'ms', 'ne', 'nl', 'no', 'pl',
                        'pt', 'ro', 'ru', 'si', 'sv', 'ta', 'th', 'tr',
                        'uk', 'ur', 'vi', 'zh',
                      ],
                      onChanged: (value) => ref
                          .read(settingsControllerProvider.notifier)
                          .updateLocaleCode(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MqSpacing.space4),
              _SettingsSection(
                title: l10n.notifications,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: Text(l10n.notifications),
                      value: preferences.notificationsEnabled,
                      onChanged: (value) => ref
                          .read(settingsControllerProvider.notifier)
                          .updateNotificationsEnabled(value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.mail_outline),
                      title: Text(l10n.emailNotifications),
                      value: preferences.emailNotifications,
                      onChanged: (value) => ref
                          .read(settingsControllerProvider.notifier)
                          .updateEmailNotifications(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MqSpacing.space4),
              _SettingsSection(
                title: l10n.settings_experience,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.map_outlined),
                      title: Text(l10n.campusMapDesc),
                      subtitle: Text(l10n.aboutDesc),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.schedule_outlined),
                      title: Text(l10n.studyPromptLabel),
                      subtitle: Text(l10n.emailNotificationsDesc),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MqSpacing.space4),
              _SettingsSection(
                title: l10n.about,
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: MqColors.red,
                          borderRadius: BorderRadius.circular(
                            MqSpacing.radiusMd,
                          ),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      title: Text(l10n.appName),
                      subtitle: Text(l10n.aboutDesc),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.code_outlined),
                      title: Text(l10n.version),
                      subtitle: const Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.people_outline),
                      title: Text(l10n.about_theTeam),
                      subtitle: const Text(
                        'Raouf Abedini & Pouya Alavi\nCOMP3130, Macquarie University',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(MqSpacing.space4),
            child: Text(l10n.settingsError),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  static String _languageLabel(String? code, AppLocalizations l10n) {
    return switch (code) {
      null  => l10n.system,
      'en'  => 'English',
      'ar'  => 'العربية',
      'bn'  => 'বাংলা',
      'cs'  => 'Čeština',
      'da'  => 'Dansk',
      'de'  => 'Deutsch',
      'el'  => 'Ελληνικά',
      'es'  => 'Español',
      'fa'  => 'فارسی',
      'fi'  => 'Suomi',
      'fr'  => 'Français',
      'he'  => 'עברית',
      'hi'  => 'हिन्दी',
      'hu'  => 'Magyar',
      'id'  => 'Bahasa Indonesia',
      'it'  => 'Italiano',
      'ja'  => '日本語',
      'ko'  => '한국어',
      'ms'  => 'Bahasa Melayu',
      'ne'  => 'नेपाली',
      'nl'  => 'Nederlands',
      'no'  => 'Norsk',
      'pl'  => 'Polski',
      'pt'  => 'Português',
      'ro'  => 'Română',
      'ru'  => 'Русский',
      'si'  => 'සිංහල',
      'sv'  => 'Svenska',
      'ta'  => 'தமிழ்',
      'th'  => 'ไทย',
      'tr'  => 'Türkçe',
      'uk'  => 'Українська',
      'ur'  => 'اردو',
      'vi'  => 'Tiếng Việt',
      'zh'  => '中文',
      _     => code.toUpperCase(),
    };
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: MqSpacing.space1,
            bottom: MqSpacing.space2,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(margin: EdgeInsets.zero, child: child),
      ],
    );
  }
}

class _DropdownListTile<T> extends StatelessWidget {
  const _DropdownListTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final T value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final Future<String?> Function(T value) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: DropdownButton<T>(
        value: value,
        underline: const SizedBox.shrink(),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              ),
            )
            .toList(),
        onChanged: (item) async {
          // item is the selected T value (can be null for "System" locale).
          final message = await onChanged(item as T);
          if (message != null && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
      ),
    );
  }
}

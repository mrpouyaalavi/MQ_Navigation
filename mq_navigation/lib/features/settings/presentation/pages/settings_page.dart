import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_navigation/app/l10n/generated/app_localizations.dart';
import 'package:mq_navigation/app/theme/mq_colors.dart';
import 'package:mq_navigation/app/theme/mq_spacing.dart';
import 'package:mq_navigation/features/settings/presentation/controllers/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: settingsState.when(
        data: (preferences) {
          return ListView(
            padding: const EdgeInsets.all(MqSpacing.space4),
            children: [
              _SettingsSection(
                title: 'General',
                child: Column(
                  children: [
                    _DropdownListTile<ThemeMode>(
                      icon: Icons.dark_mode_outlined,
                      title: l10n.appearance,
                      value: preferences.themeMode,
                      itemLabel: (value) => switch (value) {
                        ThemeMode.system => l10n.system,
                        ThemeMode.light => l10n.light,
                        ThemeMode.dark => l10n.dark,
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
                      itemLabel: (value) => switch (value) {
                        null => 'System default',
                        'en' => 'English',
                        'ar' => 'Arabic',
                        'fa' => 'Persian',
                        'zh' => 'Chinese',
                        'hi' => 'Hindi',
                        _ => value.toUpperCase(),
                      },
                      items: const [null, 'en', 'ar', 'fa', 'zh', 'hi'],
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
                      title: const Text('Email notifications'),
                      value: preferences.emailNotifications,
                      onChanged: (value) => ref
                          .read(settingsControllerProvider.notifier)
                          .updateEmailNotifications(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MqSpacing.space4),
              const _SettingsSection(
                title: 'Experience',
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.map_outlined),
                      title: Text('Campus navigation'),
                      subtitle: Text(
                        'Search 153 buildings and get walking directions across campus.',
                      ),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.schedule_outlined),
                      title: Text('Study prompts'),
                      subtitle: Text(
                        'Get daily reminders to stay on track with your schedule.',
                      ),
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
                      title: const Text('MQ Navigation'),
                      subtitle: const Text(
                        'Flutter mobile client for Macquarie University.',
                      ),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.code_outlined),
                      title: Text('Version'),
                      subtitle: Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.people_outline),
                      title: Text('Authors'),
                      subtitle: Text(
                        'Raouf Abedini & Pouya Alavi\nCOMP3130, Macquarie University',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => const Center(
          child: Padding(
            padding: EdgeInsets.all(MqSpacing.space4),
            child: Text('Unable to load your settings.'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
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
          padding: const EdgeInsets.only(
            left: MqSpacing.space1,
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
          if (item == null) {
            return;
          }
          final message = await onChanged(item);
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syllabus_sync/app/l10n/generated/app_localizations.dart';
import 'package:syllabus_sync/app/router/app_router.dart';
import 'package:syllabus_sync/app/theme/mq_theme.dart';

/// Root application widget.
class SyllabusSyncApp extends ConsumerWidget {
  const SyllabusSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Syllabus Sync',
      debugShowCheckedModeBanner: false,
      theme: MqTheme.light,
      darkTheme: MqTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syllabus_sync/core/config/env_config.dart';
import 'package:syllabus_sync/core/error/error_boundary.dart';
import 'package:syllabus_sync/core/logging/app_logger.dart';

/// Initialises all critical services before the widget tree mounts.
Future<void> bootstrap(Widget Function() appBuilder) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Install global error handlers.
  installErrorHandlers();

  // Catch errors outside the Flutter framework.
  await runZonedGuarded(
    () async {
      // Validate required env vars.
      EnvConfig.validate();

      // Initialise Supabase.
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      AppLogger.info('Supabase initialised', EnvConfig.appEnv);

      runApp(
        ProviderScope(child: appBuilder()),
      );
    },
    (error, stack) {
      AppLogger.error('Unhandled zone error', error, stack);
    },
  );
}

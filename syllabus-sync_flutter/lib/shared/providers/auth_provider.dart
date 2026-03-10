import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syllabus_sync/core/logging/app_logger.dart';

/// Reactive auth state notifier backed by Supabase auth events.
class AuthNotifier extends AsyncNotifier<Session?> {
  StreamSubscription<AuthState>? _sub;

  @override
  Future<Session?> build() async {
    final client = Supabase.instance.client;
    _sub?.cancel();
    _sub = client.auth.onAuthStateChange.listen((data) {
      AppLogger.info('Auth event', data.event.name);
      state = AsyncData(data.session);
    });
    ref.onDispose(() => _sub?.cancel());
    return client.auth.currentSession;
  }

  User? get currentUser => Supabase.instance.client.auth.currentUser;

  bool get isAuthenticated => state.value != null;

  /// Check if email is verified.
  bool get isEmailVerified =>
      currentUser?.emailConfirmedAt != null;

  /// Check if MFA is enrolled (AAL2).
  Future<bool> get isMfaVerified async {
    try {
      final aal = Supabase.instance.client.auth.mfa.getAuthenticatorAssuranceLevel();
      return aal.currentLevel == AuthenticatorAssuranceLevels.aal2;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, Session?>(
  AuthNotifier.new,
);

/// Convenience: current user or null.
final currentUserProvider = Provider<User?>((ref) {
  final session = ref.watch(authProvider).value;
  return session?.user;
});

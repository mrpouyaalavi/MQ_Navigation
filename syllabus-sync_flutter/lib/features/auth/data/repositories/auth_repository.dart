import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const mobileAuthRedirectUri = 'io.syllabussync://callback';

abstract interface class AuthRepository {
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });

  Future<bool> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<UserResponse> updatePassword(String newPassword);

  Future<ResendResponse> resendVerification(String email);

  Future<void> signOut();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(Supabase.instance.client);
});

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: mobileAuthRedirectUri,
    );
  }

  @override
  Future<bool> signInWithGoogle() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: mobileAuthRedirectUri,
    );
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _client.auth.resetPasswordForEmail(
      email,
      redirectTo: mobileAuthRedirectUri,
    );
  }

  @override
  Future<UserResponse> updatePassword(String newPassword) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<ResendResponse> resendVerification(String email) {
    return _client.auth.resend(
      email: email,
      type: OtpType.signup,
      emailRedirectTo: mobileAuthRedirectUri,
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}

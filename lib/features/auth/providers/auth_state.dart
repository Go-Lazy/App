import '../models/auth_user.dart';

/// Coarse-grained auth lifecycle. `unknown` is the brief state while a
/// persisted session is still being read from storage at app launch — the
/// UI should treat it like a loading state, not like "logged out".
enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  const AuthState._(this.status, this.user);

  const AuthState.unknown() : this._(AuthStatus.unknown, null);
  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated, null);
  const AuthState.authenticated(AuthUser user) : this._(AuthStatus.authenticated, user);

  final AuthStatus status;
  final AuthUser? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

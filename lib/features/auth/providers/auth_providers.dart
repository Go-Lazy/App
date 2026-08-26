import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_key_value_store.dart';
import '../data/auth_api.dart';
import '../repositories/api_auth_repository.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(apiClientProvider)));

final secureKeyValueStoreProvider = Provider<SecureKeyValueStore>(
  (ref) => const FlutterSecureKeyValueStore(FlutterSecureStorage()),
);

/// The active auth data source. Overriding this single provider is enough
/// to swap in a fake implementation for tests.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(ref.watch(authApiProvider), ref.watch(secureKeyValueStoreProvider));
});

/// App-wide auth state: unknown (restoring) -> unauthenticated | authenticated.
final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Notifier.build() must be synchronous; kick off the actual session
    // restore as a fire-and-forget task and start the app in `unknown`.
    Future.microtask(_restoreSession);
    return const AuthState.unknown();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> _restoreSession() async {
    final user = await _repository.restoreSession();
    if (!ref.mounted) return;
    // An explicit login/register/logout may have already resolved while
    // this was in flight (e.g. the user tapped "Log in" the instant the app
    // launched) — don't let a slow restore clobber a state that has already
    // moved on from `unknown`.
    if (state.status != AuthStatus.unknown) return;
    state = user != null ? AuthState.authenticated(user) : const AuthState.unauthenticated();
  }

  /// Returns the backend's mocked OTP (`debugOtp`) so the UI can display it
  /// while no real SMS provider is wired up; null in a build where the
  /// backend no longer echoes it.
  Future<String?> sendOtp(String phone) => _repository.sendOtp(phone);

  Future<void> register({
    required String phone,
    required String otp,
    required String password,
    String? name,
    String? email,
  }) async {
    final user = await _repository.register(
      phone: phone,
      otp: otp,
      password: password,
      name: name,
      email: email,
    );
    state = AuthState.authenticated(user);
  }

  Future<void> login({required String phone, required String password}) async {
    final user = await _repository.login(phone: phone, password: password);
    state = AuthState.authenticated(user);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState.unauthenticated();
  }
}

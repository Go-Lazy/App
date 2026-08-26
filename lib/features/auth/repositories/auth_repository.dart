import '../models/auth_user.dart';

/// Data contract for authentication. [ApiAuthRepository] is the only
/// implementation today, backed by Go-Lazy/backend's phone+password auth
/// (OTP is used once, at registration, to prove phone ownership — see
/// `docs/` for why there is no login-time OTP or session token yet).
abstract class AuthRepository {
  Future<String?> sendOtp(String phone);

  Future<AuthUser> register({
    required String phone,
    required String otp,
    required String password,
    String? name,
    String? email,
  });

  Future<AuthUser> login({required String phone, required String password});

  /// Clears the locally persisted session. Purely local: the backend has no
  /// logout endpoint or server-side session to invalidate today.
  Future<void> logout();

  /// Returns the previously persisted user, if any, so the app can restore
  /// a session on launch without asking the user to log in again.
  Future<AuthUser?> restoreSession();
}

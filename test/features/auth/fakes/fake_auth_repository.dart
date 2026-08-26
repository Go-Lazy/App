import 'package:golazy_app/features/auth/models/auth_user.dart';
import 'package:golazy_app/features/auth/repositories/auth_repository.dart';

/// Scriptable [AuthRepository] for testing [AuthController] in isolation
/// from the network and from storage.
class FakeAuthRepository implements AuthRepository {
  AuthUser? sessionToRestore;
  AuthUser? loginResult;
  AuthUser? registerResult;
  String? otpToReturn;
  Object? loginError;
  Object? registerError;
  bool loggedOut = false;

  @override
  Future<String?> sendOtp(String phone) async => otpToReturn;

  @override
  Future<AuthUser> register({
    required String phone,
    required String otp,
    required String password,
    String? name,
    String? email,
  }) async {
    if (registerError != null) throw registerError!;
    return registerResult!;
  }

  @override
  Future<AuthUser> login({required String phone, required String password}) async {
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<void> logout() async {
    loggedOut = true;
  }

  @override
  Future<AuthUser?> restoreSession() async => sessionToRestore;
}

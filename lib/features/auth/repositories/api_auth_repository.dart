import 'dart:convert';

import '../../../core/storage/secure_key_value_store.dart';
import '../data/auth_api.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

/// [AuthRepository] backed by the real GoLazy API, with the logged-in user
/// persisted to secure storage so a session survives an app restart.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, this._storage);

  final AuthApi _api;
  final SecureKeyValueStore _storage;

  static const _sessionStorageKey = 'golazy.auth.user';

  @override
  Future<String?> sendOtp(String phone) => _api.sendOtp(phone);

  @override
  Future<AuthUser> register({
    required String phone,
    required String otp,
    required String password,
    String? name,
    String? email,
  }) async {
    final user = await _api.register(
      phone: phone,
      otp: otp,
      password: password,
      name: name,
      email: email,
    );
    await _persist(user);
    return user;
  }

  @override
  Future<AuthUser> login({required String phone, required String password}) async {
    final user = await _api.login(phone: phone, password: password);
    await _persist(user);
    return user;
  }

  @override
  Future<void> logout() => _storage.delete(_sessionStorageKey);

  @override
  Future<AuthUser?> restoreSession() async {
    final raw = await _storage.read(_sessionStorageKey);
    if (raw == null) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt or outdated stored session shape: treat as logged out
      // rather than crashing app startup.
      await _storage.delete(_sessionStorageKey);
      return null;
    }
  }

  Future<void> _persist(AuthUser user) =>
      _storage.write(_sessionStorageKey, jsonEncode(user.toJson()));
}

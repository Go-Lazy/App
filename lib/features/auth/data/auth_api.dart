import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exceptions.dart';
import '../models/auth_user.dart';

/// Raw HTTP calls against the GoLazy backend's auth endpoints. Contains no
/// state and no persistence — that's [AuthRepository]'s job.
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  /// Requests an OTP for [phone]. The backend currently mocks SMS delivery
  /// and echoes the code back as `debugOtp`, which is returned here so the
  /// UI can pre-fill it in non-production builds; it will be null once the
  /// backend wires up a real SMS provider.
  Future<String?> sendOtp(String phone) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.sendOtp,
        data: {'phone': phone},
      );
      return response.data?['debugOtp'] as String?;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AuthUser> register({
    required String phone,
    required String otp,
    required String password,
    String? name,
    String? email,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'phone': phone,
          'otp': otp,
          'password': password,
          if (name != null && name.isNotEmpty) 'name': name,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      );
      return AuthUser.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AuthUser> login({required String phone, required String password}) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'phone': phone, 'password': password},
      );
      return AuthUser.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

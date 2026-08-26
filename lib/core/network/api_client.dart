import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Thin wrapper around a single, app-wide [Dio] instance. Feature data
/// sources should depend on this (via [ApiClient.dio]) rather than
/// constructing their own `Dio()`, so base URL, timeouts and future
/// interceptors (e.g. attaching an auth header once the backend issues
/// tokens) stay in one place.
class ApiClient {
  ApiClient() : dio = _buildDio();

  final Dio dio;

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: const {'Content-Type': 'application/json'},
      ),
    );
  }
}

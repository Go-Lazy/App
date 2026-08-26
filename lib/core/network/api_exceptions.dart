import 'package:dio/dio.dart';

/// Base type for every error surfaced by the GoLazy API layer. Screens
/// should catch this (not [DioException]) so the network layer stays the
/// only place that knows about Dio.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The request never reached the server (offline, DNS failure, timeout).
class ApiNetworkException extends ApiException {
  const ApiNetworkException()
      : super('Unable to reach GoLazy servers. Check your connection and try again.');
}

/// The server responded with an error. `statusCode` is null only if the
/// response body couldn't be read at all.
class ApiRequestException extends ApiException {
  const ApiRequestException(super.message, {this.statusCode});

  final int? statusCode;
}

/// Translates a raw [DioException] into a typed [ApiException], reading the
/// GoLazy backend's `{ success: false, error: "..." }` shape where present.
ApiException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const ApiNetworkException();
    default:
      final data = error.response?.data;
      String message = 'Something went wrong. Please try again.';
      if (data is Map && data['error'] is String) {
        message = data['error'] as String;
      } else if (data is Map && data['message'] is String) {
        message = data['message'] as String;
      }
      return ApiRequestException(message, statusCode: error.response?.statusCode);
  }
}

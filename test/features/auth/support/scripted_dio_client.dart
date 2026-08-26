import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:golazy_app/core/network/api_client.dart';

/// An [HttpClientAdapter] that returns one canned response for every
/// request, so Dio-based data sources can be tested without a real network
/// call. The canned bodies used in these tests mirror responses actually
/// observed from the live Go-Lazy/backend during manual verification.
class ScriptedHttpClientAdapter implements HttpClientAdapter {
  ScriptedHttpClientAdapter(this.statusCode, this.body);

  final int statusCode;
  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class ScriptedApiClient implements ApiClient {
  ScriptedApiClient(int statusCode, Map<String, dynamic> body)
      : dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
          ..httpClientAdapter = ScriptedHttpClientAdapter(statusCode, body);

  @override
  final Dio dio;
}

import 'dart:convert';

import 'package:career_readiness/core/api/api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

typedef Json = Map<String, dynamic>;

/// A failed call to the backend.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;

  /// Null when the server was never reached at all.
  final int? statusCode;

  bool get unreachable => statusCode == null;

  @override
  String toString() => 'ApiException(${statusCode ?? 'unreachable'}): $message';
}

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client})
      : _http = client ?? http.Client();

  final String baseUrl;
  final http.Client _http;

  static const _timeout = Duration(seconds: 15);

  Future<dynamic> get(String path) => _send(() => _http.get(_uri(path)));

  Future<dynamic> post(String path, Json body) => _send(() => _http.post(
        _uri(path),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ));

  void close() => _http.close();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> _send(Future<http.Response> Function() call) async {
    final http.Response response;
    try {
      response = await call().timeout(_timeout);
    } on Exception catch (e) {
      throw ApiException('could not reach $baseUrl: $e');
    }
    // Decode the raw bytes as UTF-8 explicitly rather than trusting
    // response.body's charset detection: every Arabic skill name in the app
    // passes through here.
    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(text, statusCode: response.statusCode);
    }
    return jsonDecode(text);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(baseUrl: apiBaseUrl);
  ref.onDispose(client.close);
  return client;
});

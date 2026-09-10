import 'dart:convert';

import 'package:career_readiness/core/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('Arabic survives a JSON response that declares no charset', () async {
    // FastAPI serves application/json without a charset parameter. The client
    // decodes the bytes as UTF-8 itself, so the Arabic skill names cannot be
    // mangled by charset guessing.
    final api = ApiClient(
      baseUrl: 'http://backend',
      client: MockClient((_) async => http.Response.bytes(
            utf8.encode('{"ar": "المواصفات الوظيفية"}'),
            200,
            headers: {'content-type': 'application/json'},
          )),
    );
    expect(await api.get('/x'), {'ar': 'المواصفات الوظيفية'});
  });

  test('a non-2xx response becomes an ApiException carrying the status', () {
    final api = ApiClient(
      baseUrl: 'http://backend',
      client: MockClient((_) async => http.Response('{"detail": "no profile"}', 404)),
    );
    expect(
      () => api.get('/profiles/nope/gap'),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 404)
          .having((e) => e.unreachable, 'unreachable', isFalse)),
    );
  });

  test('a connection failure is reported as unreachable', () {
    final api = ApiClient(
      baseUrl: 'http://backend',
      client: MockClient((_) async => throw http.ClientException('refused')),
    );
    expect(
      () => api.get('/careers'),
      throwsA(isA<ApiException>().having((e) => e.unreachable, 'unreachable', isTrue)),
    );
  });

  test('POST sends JSON', () async {
    late http.Request sent;
    final api = ApiClient(
      baseUrl: 'http://backend',
      client: MockClient((request) async {
        sent = request;
        return http.Response('{"id": "p1"}', 201);
      }),
    );
    await api.post('/profiles', {'career': 'Business Analyst'});
    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'http://backend/profiles');
    expect(sent.headers['Content-Type'], startsWith('application/json'));
    expect(jsonDecode(sent.body), {'career': 'Business Analyst'});
  });
}

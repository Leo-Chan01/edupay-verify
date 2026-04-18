import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:edupay_verify/core/services/http_logging_interceptor.dart';

void main() {
  group('HttpLoggingInterceptor', () {
    test('logs request and response details', () async {
      final logs = <String>[];

      final client = HttpLoggingInterceptor(
        MockClient((request) async {
          return http.Response(
            jsonEncode({'success': true, 'message': 'ok'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        onLog: logs.add,
      );

      final response = await client.post(
        Uri.parse('https://example.com/test'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'ping'}),
      );

      expect(response.statusCode, 200);
      expect(logs.any((log) => log.contains('HTTP Request')), isTrue);
      expect(logs.any((log) => log.contains('HTTP Response')), isTrue);
      expect(logs.any((log) => log.contains('action')), isTrue);
    });
  });
}

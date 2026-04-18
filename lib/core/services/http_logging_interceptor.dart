import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:edupay_verify/core/services/custom_log_file.dart';

typedef HttpLogHandler = void Function(String message);

class HttpLoggingInterceptor extends http.BaseClient {
  HttpLoggingInterceptor(this._inner, {HttpLogHandler? onLog})
    : _onLog = onLog ?? CustomLogFile.info;

  final http.Client _inner;
  final HttpLogHandler _onLog;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startedAt = DateTime.now();

    _onLog(_buildRequestLog(request));

    try {
      final response = await _inner.send(request);
      final bytes = await response.stream.toBytes();
      final responseBody = utf8.decode(bytes, allowMalformed: true);
      final elapsed = DateTime.now().difference(startedAt).inMilliseconds;

      _onLog(
        _buildResponseLog(
          request: request,
          statusCode: response.statusCode,
          elapsedMs: elapsed,
          body: responseBody,
        ),
      );

      return http.StreamedResponse(
        Stream.value(bytes),
        response.statusCode,
        contentLength: bytes.length,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (error, stackTrace) {
      CustomLogFile.error(
        'HTTP Error\n${request.method} ${request.url}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  String _buildRequestLog(http.BaseRequest request) {
    final buffer = StringBuffer()
      ..writeln('HTTP Request')
      ..writeln('${request.method} ${request.url}')
      ..writeln('Headers: ${_formatJson(_sanitizeHeaders(request.headers))}');

    if (request is http.Request && request.body.isNotEmpty) {
      buffer.writeln('Body: ${_sanitizeBody(request.body)}');
    }

    return buffer.toString().trim();
  }

  String _buildResponseLog({
    required http.BaseRequest request,
    required int statusCode,
    required int elapsedMs,
    required String body,
  }) {
    final buffer = StringBuffer()
      ..writeln('HTTP Response')
      ..writeln('${request.method} ${request.url}')
      ..writeln('Status: $statusCode')
      ..writeln('Duration: ${elapsedMs}ms');

    if (body.isNotEmpty) {
      buffer.writeln('Body: ${_sanitizeBody(body)}');
    }

    return buffer.toString().trim();
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      final lowerKey = key.toLowerCase();
      if (lowerKey == 'authorization' || lowerKey.contains('token')) {
        return MapEntry(key, '***redacted***');
      }
      return MapEntry(key, value);
    });
  }

  String _sanitizeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      final sanitized = _sanitizeJson(decoded);
      return _formatJson(sanitized);
    } catch (_) {
      return _truncate(body);
    }
  }

  dynamic _sanitizeJson(dynamic value) {
    if (value is Map) {
      return value.map((key, dynamic entryValue) {
        final normalizedKey = key.toString().toLowerCase();
        if (_sensitiveKeys.contains(normalizedKey)) {
          return MapEntry(key, '***redacted***');
        }

        return MapEntry(key, _sanitizeJson(entryValue));
      });
    }

    if (value is List) {
      return value.map(_sanitizeJson).toList();
    }

    if (value is String && value.length > 500) {
      return _truncate(value);
    }

    return value;
  }

  String _formatJson(dynamic value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  String _truncate(String value) {
    if (value.length <= 500) {
      return value;
    }

    return '${value.substring(0, 500)}...';
  }

  static const Set<String> _sensitiveKeys = {
    'password',
    'auth_token',
    'session_token',
    'csrf_token',
    'authorization',
    'logo_base64',
  };
}

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/core/services/custom_log_file.dart';
import 'package:edupay_verify/core/services/http_logging_interceptor.dart';
import 'package:edupay_verify/features/auth/data/models/admin_model.dart';
import 'package:edupay_verify/features/verification/models/receipt_model.dart';

final edupayApiServiceProvider = Provider<EduPayApiService>((ref) {
  return EduPayApiService();
});

class EduPayApiService {
  EduPayApiService({http.Client? client})
    : _client = client ?? HttpLoggingInterceptor(http.Client());

  static const String baseUrl = 'https://api.edupay.africa/backend/api/v1/';

  final http.Client _client;

  Future<AdminModel> adminLogin({
    required String email,
    required String password,
  }) async {
    final response = await _postAction(
      body: {'action': 'admin_login', 'email': email, 'password': password},
    );

    final user = Map<String, dynamic>.from(response['user'] as Map? ?? {});

    return AdminModel(
      id: _asString(user['id'] ?? user['user_id']),
      name: _asString(user['name'], fallback: email),
      username: _asString(user['email'] ?? user['username'], fallback: email),
      email: _asString(user['email'], fallback: email),
      authToken: _asString(response['auth_token'] ?? user['session_token']),
      userLevel: _asString(user['userlevel']),
    );
  }

  Future<List<Map<String, dynamic>>> getTransactions({
    required String authToken,
    int page = 1,
    int rowsPerPage = 10,
    String search = '',
    String status = 'success',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final response = await _postAction(
      body: {
        'action': 'get_transactions',
        'auth_token': authToken,
        'page': page,
        'rows_per_page': rowsPerPage,
        'search': search,
        'status': status,
        'date_from': _formatDate(dateFrom ?? DateTime(2024)),
        'date_to': _formatDate(dateTo ?? DateTime(2026, 12, 31)),
      },
    );

    final setup = Map<String, dynamic>.from(response['setup'] as Map? ?? {});
    final currency = _asString(setup['currency'], fallback: 'NGN');
    final transactions = response['transactions'] as List<dynamic>? ?? const [];

    return transactions
        .whereType<Map>()
        .map(
          (transaction) => normalizeTransaction(
            Map<String, dynamic>.from(transaction),
            currency: currency,
          ),
        )
        .toList();
  }

  Future<ReceiptModel> findReceiptByIdentifier({
    required String authToken,
    required String identifier,
  }) async {
    final normalizedIdentifier = identifier.trim().toLowerCase();

    final records = await getTransactions(
      authToken: authToken,
      rowsPerPage: 50,
      search: identifier.trim(),
    );

    final record = records.firstWhere(
      (item) => _matchesIdentifier(item, normalizedIdentifier),
      orElse: () => throw Exception(AppStrings.receiptNotFound),
    );

    return ReceiptModel.fromJson({
      ...record,
      'verification_time': DateTime.now().toIso8601String(),
      'offline': false,
    });
  }

  Map<String, dynamic> normalizeTransaction(
    Map<String, dynamic> transaction, {
    String currency = 'NGN',
  }) {
    final receiptId = _asString(
      transaction['receipt_number'],
      fallback: _asString(
        transaction['transaction_reference'],
        fallback: _asString(
          transaction['payment_reference'],
          fallback: _asString(transaction['transaction_id']),
        ),
      ),
    );

    return {
      'receipt_id': receiptId,
      'reference': _asString(
        transaction['payment_reference'],
        fallback: _asString(
          transaction['transaction_reference'],
          fallback: receiptId,
        ),
      ),
      'student_name': _asString(
        transaction['student_name'],
        fallback: 'Unknown Student',
      ),
      'student_id': _asString(
        transaction['student_reg'] ?? transaction['admission_email'],
        fallback: 'N/A',
      ),
      'program': _asString(
        transaction['student_program'] ?? transaction['admission_program'],
        fallback: 'N/A',
      ),
      'session': _asString(transaction['student_session'], fallback: 'N/A'),
      'transaction_id': _asString(
        transaction['transaction_reference'],
        fallback: _asString(transaction['transaction_id'], fallback: receiptId),
      ),
      'description': _asString(
        transaction['description'],
        fallback: _asString(transaction['fee_name'], fallback: 'Payment'),
      ),
      'amount': _formatCurrency(transaction['amount'], currency),
      'payment_type': _asString(
        transaction['paymentType'] ?? transaction['type'],
        fallback: 'Payment',
      ),
      'fees_total_paid': _formatCurrency(
        transaction['total_amount_paid'],
        currency,
      ),
      'outstanding': _formatCurrency(transaction['outstanding'], currency),
      'date_time': _asString(
        transaction['date'],
        fallback: DateTime.now().toIso8601String(),
      ),
      'payment_method': _asString(
        transaction['method'] ?? transaction['payment_source'],
        fallback: 'online',
      ),
      'status': _asString(transaction['status'], fallback: 'unknown'),
      'remarks': _asString(transaction['description']),
    };
  }

  Future<Map<String, dynamic>> _postAction({
    required Map<String, dynamic> body,
  }) async {
    final response = await _client.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      CustomLogFile.error(
        'API request failed with status ${response.statusCode} for action ${body['action']}',
      );
      throw Exception(AppStrings.downloadFailed);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      CustomLogFile.error(
        'API returned a non-map response for action ${body['action']}',
      );
      throw Exception(AppStrings.invalidCredentials);
    }

    if (decoded['success'] != true) {
      final message = _asString(
        decoded['message'],
        fallback: AppStrings.invalidCredentials,
      );
      CustomLogFile.error(
        'API business failure for action ${body['action']}: $message',
      );
      throw Exception(message);
    }

    return decoded;
  }

  bool _matchesIdentifier(Map<String, dynamic> record, String identifier) {
    final candidates = [
      record['receipt_id'],
      record['reference'],
      record['transaction_id'],
      record['student_id'],
    ];

    return candidates.any((value) {
      final text = _asString(value).toLowerCase();
      return text.isNotEmpty &&
          (text == identifier || text.contains(identifier));
    });
  }

  String _formatCurrency(dynamic value, String currency) {
    final amount = _asDouble(value);
    final symbol = currency.toUpperCase() == 'NGN' ? '₦' : '$currency ';
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    ).format(amount);
  }

  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

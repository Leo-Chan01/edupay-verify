import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edupay_verify/core/services/edupay_api_service.dart';
import 'package:edupay_verify/core/services/storage_service.dart';
import 'package:edupay_verify/features/history/providers/history_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('history notifier refreshes from get_transactions endpoint', () async {
    await StorageService.saveAdmin(
      jsonEncode({
        'id': '1',
        'name': 'Admin',
        'username': 'admin@edupay.africa',
        'email': 'admin@edupay.africa',
        'auth_token': 'token-123',
      }),
    );

    final service = EduPayApiService(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'transactions': [
              {
                'transaction_id': '445',
                'payment_reference': 'TXREF123',
                'receipt_number': 'RCPT-123',
                'description': 'Payment for Tuition Fee',
                'amount': 5000,
                'date': '2026-04-17 14:03:48',
                'method': 'online',
                'status': 'success',
                'student_name': 'Jane Doe',
                'student_reg': 'EOCNS/25/0070/GNS',
                'student_program': 'Nursing',
                'student_session': '2025/2026',
                'paymentType': 'Part Payment',
                'outstanding': 0,
                'total_amount_paid': 5000,
              },
            ],
            'setup': {'currency': 'NGN'},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final notifier = HistoryNotifier(service, () => 'token-123');
    await notifier.refreshHistory();

    expect(notifier.state.length, 1);
    expect(notifier.state.first.receiptId, 'RCPT-123');
    expect(notifier.state.first.studentName, 'Jane Doe');
  });

  test('history notifier prefers the current login token', () async {
    await StorageService.saveAdmin(
      jsonEncode({
        'id': '1',
        'name': 'Admin',
        'username': 'admin@edupay.africa',
        'email': 'admin@edupay.africa',
        'auth_token': 'expired-token',
      }),
    );

    final service = EduPayApiService(
      client: MockClient((request) async {
        final requestBody = jsonDecode(request.body) as Map<String, dynamic>;

        if (requestBody['auth_token'] != 'fresh-login-token') {
          return http.Response(
            jsonEncode({
              'success': false,
              'message': 'Invalid or expired token',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response(
          jsonEncode({
            'success': true,
            'transactions': [
              {
                'transaction_id': '999',
                'payment_reference': 'LIVE-TOKEN-REF',
                'receipt_number': 'RCPT-LIVE-999',
                'description': 'Payment for Tuition Fee',
                'amount': 1000,
                'date': '2026-04-17 14:03:48',
                'method': 'online',
                'status': 'success',
                'student_name': 'Live Token User',
                'student_reg': 'EOCNS/25/0001/GNS',
                'student_program': 'Nursing',
                'student_session': '2025/2026',
                'paymentType': 'Part Payment',
                'outstanding': 0,
                'total_amount_paid': 1000,
              },
            ],
            'setup': {'currency': 'NGN'},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final notifier = HistoryNotifier(service, () => 'fresh-login-token');
    await notifier.refreshHistory();

    expect(notifier.state.length, 1);
    expect(notifier.state.first.receiptId, 'RCPT-LIVE-999');
  });
}

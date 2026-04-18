import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:edupay_verify/core/services/edupay_api_service.dart';

void main() {
  group('EduPayApiService', () {
    test('adminLogin maps the response to an admin session', () async {
      final client = MockClient((request) async {
        return http.Response(
          '{"success":true,"auth_token":"token-123","user":{"id":1,"name":"Jc Favour","email":"admin@edupay.africa","userlevel":"admin"}}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = EduPayApiService(client: client);
      final admin = await service.adminLogin(
        email: 'admin@edupay.africa',
        password: 'secret',
      );

      expect(admin.id, '1');
      expect(admin.name, 'Jc Favour');
      expect(admin.username, 'admin@edupay.africa');
      expect(admin.email, 'admin@edupay.africa');
      expect(admin.authToken, 'token-123');
    });

    test('findReceiptByIdentifier maps a transaction to receipt model', () async {
      final client = MockClient((request) async {
        return http.Response(
          '{"success":true,"transactions":[{"transaction_id":"445","payment_reference":"TXREF_FEES_1_1776430841_532272","receipt_number":"RCPT-1776431028-5288","description":"Payment for Tuition Fee","fee_name":"Tuition Fee","amount":359325,"date":"2026-04-17 14:03:48","method":"online","status":"success","student_name":"SHULAMITE Modestus Nzubechi","student_reg":"EOCNS/25/0070/GNS","student_program":"Nursing","student_session":"2025/2026","paymentType":"Part Payment","outstanding":0,"total_amount_paid":838425}],"setup":{"currency":"NGN"}}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = EduPayApiService(client: client);
      final receipt = await service.findReceiptByIdentifier(
        authToken: 'token-123',
        identifier: 'RCPT-1776431028-5288',
      );

      expect(receipt.receiptId, 'RCPT-1776431028-5288');
      expect(receipt.studentName, 'SHULAMITE Modestus Nzubechi');
      expect(receipt.studentId, 'EOCNS/25/0070/GNS');
      expect(receipt.status.toLowerCase(), 'success');
      expect(receipt.amount.contains('₦'), isTrue);
    });

    test('getTransactions throws for invalid tokens', () async {
      final client = MockClient((request) async {
        return http.Response(
          '{"success":false,"message":"Invalid or expired token"}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = EduPayApiService(client: client);

      expect(
        () => service.getTransactions(authToken: 'expired-token'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

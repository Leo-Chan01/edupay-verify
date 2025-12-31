import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/features/verification/models/receipt_model.dart';
import 'package:edupay_verify/core/services/storage_service.dart';

class VerificationService {
  Future<ReceiptModel> verifyOnline(String identifier) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data matching HTML sample
    return ReceiptModel(
      receiptId: identifier,
      reference: 'EOCNS/24/0002/GNS',
      studentName: 'Demo One',
      studentId: 'EOCNS/24/0002/GNS',
      program: 'Medical Science',
      session: '2025/2026',
      transactionId:
          identifier.startsWith('RCPT') ? identifier : 'RCPT-${DateTime.now().millisecondsSinceEpoch}-3617',
      description: 'Payment for Tuition Fee',
      amount: '₦110.00',
      paymentType: 'Part Payment',
      feesTotalPaid: '₦4,410.00',
      outstanding: '₦45,590.00',
      dateTime: '27 Dec 2025, 16:50',
      paymentMethod: 'online',
      status: 'Success',
      remarks: 'Semester tuition fee payment',
      verificationTime: DateTime.now().toIso8601String(),
    );
  }

  Future<ReceiptModel> verifyOffline(String identifier) async {
    final offlineDataJson = StorageService.getOfflineData();
    if (offlineDataJson == null) {
      throw Exception('No offline data available. Please download records first.');
    }

    final offlineData = jsonDecode(offlineDataJson) as Map<String, dynamic>;
    final records = offlineData['records'] as List<dynamic>;

    final record = records.firstWhere(
      (rec) {
        final r = rec as Map<String, dynamic>;
        return r['receipt_id'] == identifier ||
            r['reference'] == identifier ||
            r['transaction_id'] == identifier ||
            r['student_id'] == identifier;
      },
      orElse: () => throw Exception('Receipt not found in offline data'),
    );

    final receiptData = record as Map<String, dynamic>;
    return ReceiptModel.fromJson({
      ...receiptData,
      'verification_time': DateTime.now().toIso8601String(),
      'offline': true,
    });
  }
}

final verificationServiceProvider = Provider<VerificationService>((ref) {
  return VerificationService();
});

class VerificationNotifier extends StateNotifier<AsyncValue<ReceiptModel?>> {
  final VerificationService _service;
  final bool Function() _isOnline;

  VerificationNotifier(this._service, this._isOnline)
      : super(const AsyncValue.data(null));

  Future<void> verifyReceipt(String identifier) async {
    state = const AsyncValue.loading();

    try {
      final receipt = _isOnline()
          ? await _service.verifyOnline(identifier)
          : await _service.verifyOffline(identifier);

      state = AsyncValue.data(receipt);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clearReceipt() {
    state = const AsyncValue.data(null);
  }
}

final verificationProvider =
    StateNotifierProvider<VerificationNotifier, AsyncValue<ReceiptModel?>>(
        (ref) {
  final service = ref.watch(verificationServiceProvider);
  return VerificationNotifier(
    service,
    () {
      // This will be properly connected to connectivity service
      return true;
    },
  );
});

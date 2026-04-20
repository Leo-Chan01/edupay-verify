import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/core/services/edupay_api_service.dart';
import 'package:edupay_verify/core/services/storage_service.dart';
import 'package:edupay_verify/features/auth/data/models/admin_model.dart';
import 'package:edupay_verify/features/auth/providers/auth_provider.dart';
import 'package:edupay_verify/features/verification/models/receipt_model.dart';

class VerificationService {
  VerificationService(this._apiService, this._readAuthToken);

  final EduPayApiService _apiService;
  final String? Function() _readAuthToken;

  Future<ReceiptModel> verifyOnline(String identifier) async {
    final authToken = _readAuthToken() ?? _readStoredAuthToken();

    if (authToken == null || authToken.isEmpty) {
      throw Exception(AppStrings.sessionExpiredPleaseLogin);
    }

    return _apiService.findReceiptByIdentifier(
      authToken: authToken,
      identifier: identifier,
    );
  }

  String? _readStoredAuthToken() {
    final savedAdmin = StorageService.getAdmin();
    if (savedAdmin == null) {
      return null;
    }

    final adminJson = jsonDecode(savedAdmin) as Map<String, dynamic>;
    final admin = AdminModel.fromJson(adminJson);
    return admin.authToken;
  }

  Future<ReceiptModel> verifyOffline(String identifier) async {
    final offlineDataJson = StorageService.getOfflineData();
    if (offlineDataJson == null) {
      throw Exception(
        'No offline data available. Please download records first.',
      );
    }

    final offlineData = jsonDecode(offlineDataJson) as Map<String, dynamic>;
    final records = offlineData['records'] as List<dynamic>;

    final record = records.firstWhere((rec) {
      final r = rec as Map<String, dynamic>;
      return r['receipt_id'] == identifier ||
          r['reference'] == identifier ||
          r['transaction_id'] == identifier ||
          r['student_id'] == identifier;
    }, orElse: () => throw Exception('Receipt not found in offline data'));

    final receiptData = record as Map<String, dynamic>;
    return ReceiptModel.fromJson({
      ...receiptData,
      'verification_time': DateTime.now().toIso8601String(),
      'offline': true,
    });
  }
}

final verificationServiceProvider = Provider<VerificationService>((ref) {
  final apiService = ref.watch(edupayApiServiceProvider);
  final authToken = ref.watch(
    authProvider.select((state) => state.admin?.authToken),
  );

  return VerificationService(apiService, () => authToken);
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
    StateNotifierProvider<VerificationNotifier, AsyncValue<ReceiptModel?>>((
      ref,
    ) {
      final service = ref.watch(verificationServiceProvider);
      return VerificationNotifier(service, () {
        // This will be properly connected to connectivity service
        return true;
      });
    });

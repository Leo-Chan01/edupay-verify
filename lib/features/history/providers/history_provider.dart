import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/core/services/edupay_api_service.dart';
import 'package:edupay_verify/core/services/storage_service.dart';
import 'package:edupay_verify/features/auth/data/models/admin_model.dart';
import 'package:edupay_verify/features/auth/providers/auth_provider.dart';
import 'package:edupay_verify/features/history/models/history_item_model.dart';
import 'package:edupay_verify/features/verification/models/receipt_model.dart';

class HistoryNotifier extends StateNotifier<List<HistoryItemModel>> {
  HistoryNotifier(this._apiService, this._readAuthToken) : super([]) {
    _loadHistory();
    refreshHistory();
  }

  final EduPayApiService _apiService;
  final String? Function() _readAuthToken;

  Future<void> _loadHistory() async {
    try {
      final historyJson = StorageService.getVerificationHistory();
      if (historyJson != null) {
        final historyList = (jsonDecode(historyJson) as List<dynamic>)
            .map(
              (item) => HistoryItemModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        state = historyList;
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> refreshHistory() async {
    try {
      final authToken = _readAuthToken() ?? _readStoredAuthToken();
      if (authToken == null || authToken.isEmpty) {
        return;
      }

      final transactions = await _apiService.getTransactions(
        authToken: authToken,
        rowsPerPage: 100,
      );

      state = transactions
          .map((item) => HistoryItemModel.fromJson(item))
          .toList();

      await _saveHistory();
    } catch (_) {
      // Fallback to cached history when the live request fails.
    }
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

  Future<void> addToHistory(ReceiptModel receipt) async {
    final historyItem = HistoryItemModel.fromReceipt(receipt);
    state = [historyItem, ...state];

    if (state.length > 100) {
      state = state.take(100).toList();
    }

    await _saveHistory();
  }

  Future<void> clearHistory() async {
    state = [];
    await StorageService.clearVerificationHistory();
  }

  Future<void> _saveHistory() async {
    try {
      final historyJson = jsonEncode(
        state.map((item) => item.toJson()).toList(),
      );
      await StorageService.saveVerificationHistory(historyJson);
    } catch (e) {
      // Handle error silently
    }
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryItemModel>>((ref) {
      final apiService = ref.watch(edupayApiServiceProvider);
      final authToken = ref.watch(
        authProvider.select((state) => state.admin?.authToken),
      );

      return HistoryNotifier(apiService, () => authToken);
    });

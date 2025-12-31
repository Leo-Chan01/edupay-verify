import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/core/services/storage_service.dart';
import 'package:edupay_verify/features/history/models/history_item_model.dart';
import 'package:edupay_verify/features/verification/models/receipt_model.dart';

class HistoryNotifier extends StateNotifier<List<HistoryItemModel>> {
  HistoryNotifier() : super([]) {
    _loadHistory();
  }

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

  Future<void> addToHistory(ReceiptModel receipt) async {
    final historyItem = HistoryItemModel.fromReceipt(receipt);
    state = [historyItem, ...state];

    // Keep only last 100 items
    if (state.length > 100) {
      state = state.take(100).toList();
    }

    // Save to storage
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
      return HistoryNotifier();
    });

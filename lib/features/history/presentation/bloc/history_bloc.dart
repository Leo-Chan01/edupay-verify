import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edupay_verify/core/services/edupay_api_service.dart';
import 'package:edupay_verify/core/services/storage_service.dart';
import 'package:edupay_verify/features/auth/data/models/admin_model.dart';
import 'package:edupay_verify/features/history/models/history_item_model.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final EduPayApiService _apiService;
  final String? Function() _readAuthToken;

  HistoryBloc({
    required EduPayApiService apiService,
    required String? Function() readAuthToken,
  }) : _apiService = apiService,
       _readAuthToken = readAuthToken,
       super(const HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<AddToHistoryEvent>(_onAddToHistory);
    on<ClearHistoryEvent>(_onClearHistory);
    on<RefreshHistoryEvent>(_onRefreshHistory);
    
    add(const LoadHistoryEvent());
    add(const RefreshHistoryEvent());
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      final historyJson = StorageService.getVerificationHistory();
      if (historyJson != null) {
        final historyList = (jsonDecode(historyJson) as List<dynamic>)
            .map(
              (item) => HistoryItemModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        emit(HistoryLoaded(historyList));
      }
    } catch (_) {}
  }

  Future<void> _onRefreshHistory(
    RefreshHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      final authToken = _readAuthToken() ?? _readStoredAuthToken();
      if (authToken == null || authToken.isEmpty) return;

      final transactions = await _apiService.getTransactions(
        authToken: authToken,
        rowsPerPage: 100,
      );

      final items = transactions.map((item) => HistoryItemModel.fromJson(item)).toList();
      emit(HistoryLoaded(items));
      await _saveHistory(items);
    } catch (_) {}
  }

  Future<void> _onAddToHistory(
    AddToHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final historyItem = HistoryItemModel.fromReceipt(event.receipt);
    final items = [historyItem, ...state.items];
    
    final updatedItems = items.length > 100 ? items.take(100).toList() : items;
    emit(HistoryLoaded(updatedItems));
    await _saveHistory(updatedItems);
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoaded([]));
    await StorageService.clearVerificationHistory();
  }

  String? _readStoredAuthToken() {
    final savedAdmin = StorageService.getAdmin();
    if (savedAdmin == null) return null;

    final adminJson = jsonDecode(savedAdmin) as Map<String, dynamic>;
    final admin = AdminModel.fromJson(adminJson);
    return admin.authToken;
  }

  Future<void> _saveHistory(List<HistoryItemModel> items) async {
    try {
      final historyJson = jsonEncode(items.map((item) => item.toJson()).toList());
      await StorageService.saveVerificationHistory(historyJson);
    } catch (_) {}
  }
}

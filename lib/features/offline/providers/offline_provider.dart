import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/core/services/edupay_api_service.dart';
import 'package:edupay_verify/core/services/storage_service.dart';
import 'package:edupay_verify/features/auth/data/models/admin_model.dart';
import 'package:edupay_verify/features/auth/providers/auth_provider.dart';
import 'package:edupay_verify/features/offline/models/offline_data_model.dart';

class OfflineNotifier extends StateNotifier<OfflineDataModel?> {
  OfflineNotifier(this._apiService, this._readAuthToken) : super(null) {
    _loadOfflineData();
  }

  final EduPayApiService _apiService;
  final String? Function() _readAuthToken;

  void _loadOfflineData() {
    final dataJson = StorageService.getOfflineData();
    if (dataJson != null) {
      try {
        state = OfflineDataModel.fromJsonString(dataJson);
      } catch (_) {
        state = null;
      }
    }
  }

  Future<int> downloadOfflineData({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final authToken = _readAuthToken() ?? _readStoredAuthToken();
    if (authToken == null || authToken.isEmpty) {
      throw Exception(AppStrings.sessionExpiredPleaseLogin);
    }

    final records = await _apiService.getTransactions(
      authToken: authToken,
      rowsPerPage: 200,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    if (records.isEmpty) {
      throw Exception(AppStrings.noRecordsFoundForSelectedDateRange);
    }

    final offlineData = OfflineDataModel(
      records: records,
      downloadedAt: DateTime.now(),
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    await saveOfflineData(offlineData);
    return records.length;
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

  Future<void> saveOfflineData(OfflineDataModel data) async {
    await StorageService.saveOfflineData(data.toJsonString());
    state = data;
  }

  Future<void> clearOfflineData() async {
    await StorageService.clearOfflineData();
    state = null;
  }

  bool isDataAvailable() => state != null && state!.records.isNotEmpty;

  int getRecordCount() => state?.recordCount ?? 0;
}

final offlineProvider =
    StateNotifierProvider<OfflineNotifier, OfflineDataModel?>((ref) {
      final apiService = ref.watch(edupayApiServiceProvider);
      final authToken = ref.watch(
        authProvider.select((state) => state.admin?.authToken),
      );

      return OfflineNotifier(apiService, () => authToken);
    });

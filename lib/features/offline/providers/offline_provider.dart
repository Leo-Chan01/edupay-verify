import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/features/offline/models/offline_data_model.dart';
import 'package:edupay_verify/core/services/storage_service.dart';

class OfflineNotifier extends StateNotifier<OfflineDataModel?> {
  OfflineNotifier() : super(null) {
    _loadOfflineData();
  }

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
    StateNotifierProvider<OfflineNotifier, OfflineDataModel?>(
      (ref) => OfflineNotifier(),
    );

import 'dart:convert';

class OfflineDataModel {
  final List<Map<String, dynamic>> records;
  final DateTime downloadedAt;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  OfflineDataModel({
    required this.records,
    required this.downloadedAt,
    this.dateFrom,
    this.dateTo,
  });

  int get recordCount => records.length;

  Map<String, dynamic> toJson() {
    return {
      'records': records,
      'downloaded_at': downloadedAt.toIso8601String(),
      'date_from': dateFrom?.toIso8601String(),
      'date_to': dateTo?.toIso8601String(),
    };
  }

  factory OfflineDataModel.fromJson(Map<String, dynamic> json) {
    return OfflineDataModel(
      records: List<Map<String, dynamic>>.from(json['records'] ?? []),
      downloadedAt: DateTime.parse(
        json['downloaded_at'] ?? DateTime.now().toIso8601String(),
      ),
      dateFrom: json['date_from'] != null
          ? DateTime.parse(json['date_from'])
          : null,
      dateTo: json['date_to'] != null ? DateTime.parse(json['date_to']) : null,
    );
  }

  factory OfflineDataModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return OfflineDataModel.fromJson(json);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

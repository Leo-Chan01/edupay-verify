import 'package:edupay_verify/features/verification/models/receipt_model.dart';

class HistoryItemModel {
  final String receiptId;
  final String transactionId;
  final String studentName;
  final String studentId;
  final String program;
  final String amount;
  final String status;
  final String dateTime;
  final String verificationTime;
  final bool offline;

  HistoryItemModel({
    required this.receiptId,
    required this.transactionId,
    required this.studentName,
    required this.studentId,
    required this.program,
    required this.amount,
    required this.status,
    required this.dateTime,
    required this.verificationTime,
    this.offline = false,
  });

  factory HistoryItemModel.fromReceipt(ReceiptModel receipt) {
    return HistoryItemModel(
      receiptId: receipt.receiptId,
      transactionId: receipt.transactionId,
      studentName: receipt.studentName,
      studentId: receipt.studentId,
      program: receipt.program,
      amount: receipt.amount,
      status: receipt.status,
      dateTime: receipt.dateTime,
      verificationTime: receipt.verificationTime,
      offline: receipt.offline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receipt_id': receiptId,
      'transaction_id': transactionId,
      'student_name': studentName,
      'student_id': studentId,
      'program': program,
      'amount': amount,
      'status': status,
      'date_time': dateTime,
      'verification_time': verificationTime,
      'offline': offline,
    };
  }

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      receiptId: json['receipt_id']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? 'N/A',
      program: json['program']?.toString() ?? 'N/A',
      amount: json['amount']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dateTime: json['date_time']?.toString() ?? '',
      verificationTime:
          json['verification_time']?.toString() ??
          json['date_time']?.toString() ??
          DateTime.now().toIso8601String(),
      offline: json['offline'] as bool? ?? false,
    );
  }
}

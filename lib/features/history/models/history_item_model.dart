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
      receiptId: json['receipt_id'] as String,
      transactionId: json['transaction_id'] as String,
      studentName: json['student_name'] as String,
      studentId: json['student_id'] as String,
      program: json['program'] as String,
      amount: json['amount'] as String,
      status: json['status'] as String,
      dateTime: json['date_time'] as String,
      verificationTime: json['verification_time'] as String,
      offline: json['offline'] as bool? ?? false,
    );
  }
}

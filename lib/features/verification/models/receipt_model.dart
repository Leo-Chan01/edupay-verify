class ReceiptModel {
  final String receiptId;
  final String reference;
  final String studentName;
  final String studentId;
  final String program;
  final String session;
  final String transactionId;
  final String description;
  final String amount;
  final String paymentType;
  final String feesTotalPaid;
  final String outstanding;
  final String dateTime;
  final String paymentMethod;
  final String status;
  final String? remarks;
  final String verificationTime;
  final bool offline;

  ReceiptModel({
    required this.receiptId,
    required this.reference,
    required this.studentName,
    required this.studentId,
    required this.program,
    required this.session,
    required this.transactionId,
    required this.description,
    required this.amount,
    required this.paymentType,
    required this.feesTotalPaid,
    required this.outstanding,
    required this.dateTime,
    required this.paymentMethod,
    required this.status,
    this.remarks,
    required this.verificationTime,
    this.offline = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'receipt_id': receiptId,
      'reference': reference,
      'student_name': studentName,
      'student_id': studentId,
      'program': program,
      'session': session,
      'transaction_id': transactionId,
      'description': description,
      'amount': amount,
      'payment_type': paymentType,
      'fees_total_paid': feesTotalPaid,
      'outstanding': outstanding,
      'date_time': dateTime,
      'payment_method': paymentMethod,
      'status': status,
      'remarks': remarks,
      'verification_time': verificationTime,
      'offline': offline,
    };
  }

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      receiptId: _stringValue(json['receipt_id']),
      reference: _stringValue(json['reference']),
      studentName: _stringValue(json['student_name']),
      studentId: _stringValue(json['student_id'], fallback: 'N/A'),
      program: _stringValue(json['program'], fallback: 'N/A'),
      session: _stringValue(json['session'], fallback: 'N/A'),
      transactionId: _stringValue(json['transaction_id']),
      description: _stringValue(json['description']),
      amount: _stringValue(json['amount']),
      paymentType: _stringValue(json['payment_type']),
      feesTotalPaid: _stringValue(json['fees_total_paid']),
      outstanding: _stringValue(json['outstanding']),
      dateTime: _stringValue(json['date_time']),
      paymentMethod: _stringValue(json['payment_method']),
      status: _stringValue(json['status']),
      remarks: json['remarks']?.toString(),
      verificationTime: _stringValue(
        json['verification_time'],
        fallback: DateTime.now().toIso8601String(),
      ),
      offline: json['offline'] as bool? ?? false,
    );
  }

  static String _stringValue(dynamic value, {String fallback = ''}) {
    final text = value?.toString() ?? '';
    return text.isEmpty ? fallback : text;
  }

  bool get isValid => status.toLowerCase() == 'success';
}

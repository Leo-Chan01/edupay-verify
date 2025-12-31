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
      receiptId: json['receipt_id'] as String,
      reference: json['reference'] as String,
      studentName: json['student_name'] as String,
      studentId: json['student_id'] as String,
      program: json['program'] as String,
      session: json['session'] as String,
      transactionId: json['transaction_id'] as String,
      description: json['description'] as String,
      amount: json['amount'] as String,
      paymentType: json['payment_type'] as String,
      feesTotalPaid: json['fees_total_paid'] as String,
      outstanding: json['outstanding'] as String,
      dateTime: json['date_time'] as String,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
      verificationTime: json['verification_time'] as String,
      offline: json['offline'] as bool? ?? false,
    );
  }

  bool get isValid => status.toLowerCase() == 'success';
}

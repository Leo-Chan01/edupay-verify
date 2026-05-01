import 'package:equatable/equatable.dart';
import 'package:edupay_verify/features/verification/models/receipt_model.dart';

abstract class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object?> get props => [];
}

class VerificationInitial extends VerificationState {
  const VerificationInitial();
}

class VerificationLoading extends VerificationState {
  const VerificationLoading();
}

class VerificationSuccess extends VerificationState {
  final ReceiptModel receipt;

  const VerificationSuccess(this.receipt);

  @override
  List<Object?> get props => [receipt];
}

class VerificationError extends VerificationState {
  final String message;

  const VerificationError(this.message);

  @override
  List<Object?> get props => [message];
}

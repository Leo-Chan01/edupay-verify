import 'package:equatable/equatable.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

class VerifyReceiptEvent extends VerificationEvent {
  final String identifier;

  const VerifyReceiptEvent(this.identifier);

  @override
  List<Object?> get props => [identifier];
}

class ClearReceiptEvent extends VerificationEvent {
  const ClearReceiptEvent();
}

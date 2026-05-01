import 'package:equatable/equatable.dart';
import 'package:edupay_verify/features/verification/models/receipt_model.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistoryEvent extends HistoryEvent {
  const LoadHistoryEvent();
}

class AddToHistoryEvent extends HistoryEvent {
  final ReceiptModel receipt;

  const AddToHistoryEvent(this.receipt);

  @override
  List<Object?> get props => [receipt];
}

class ClearHistoryEvent extends HistoryEvent {
  const ClearHistoryEvent();
}

class RefreshHistoryEvent extends HistoryEvent {
  const RefreshHistoryEvent();
}

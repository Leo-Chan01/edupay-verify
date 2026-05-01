import 'package:equatable/equatable.dart';
import 'package:edupay_verify/features/history/models/history_item_model.dart';

abstract class HistoryState extends Equatable {
  final List<HistoryItemModel> items;

  const HistoryState(this.items);

  @override
  List<Object?> get props => [items];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial() : super(const []);
}

class HistoryLoaded extends HistoryState {
  const HistoryLoaded(super.items);
}

class HistoryLoading extends HistoryState {
  const HistoryLoading(super.items);
}

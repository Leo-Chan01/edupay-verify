import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edupay_verify/core/services/connectivity_service.dart';
import 'package:edupay_verify/features/verification/providers/verification_provider.dart';
import 'verification_event.dart';
import 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final VerificationService _service;
  final ConnectivityService _connectivityService;

  VerificationBloc({
    required VerificationService service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService,
       super(const VerificationInitial()) {
    on<VerifyReceiptEvent>(_onVerifyReceipt);
    on<ClearReceiptEvent>(_onClearReceipt);
  }

  Future<void> _onVerifyReceipt(
    VerifyReceiptEvent event,
    Emitter<VerificationState> emit,
  ) async {
    emit(const VerificationLoading());

    try {
      final isOnline = await _connectivityService.checkConnectivity();
      
      final receipt = isOnline
          ? await _service.verifyOnline(event.identifier)
          : await _service.verifyOffline(event.identifier);

      emit(VerificationSuccess(receipt));
    } catch (e) {
      emit(VerificationError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onClearReceipt(
    ClearReceiptEvent event,
    Emitter<VerificationState> emit,
  ) {
    emit(const VerificationInitial());
  }
}

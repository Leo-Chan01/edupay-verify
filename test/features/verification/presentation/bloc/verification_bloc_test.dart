import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:edupay_verify/core/services/connectivity_service.dart';
import 'package:edupay_verify/features/verification/models/receipt_model.dart';
import 'package:edupay_verify/features/verification/providers/verification_provider.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_event.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_state.dart';

class MockVerificationService extends Mock implements VerificationService {}
class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late VerificationBloc verificationBloc;
  late MockVerificationService mockService;
  late MockConnectivityService mockConnectivity;

  final tReceipt = ReceiptModel(
    receiptId: 'TXN123',
    reference: 'REF123',
    studentName: 'John Doe',
    studentId: 'STU123',
    program: 'Comp Sci',
    session: '2024',
    transactionId: 'TXN123',
    description: 'Fees',
    amount: '1000',
    paymentType: 'Tuition',
    feesTotalPaid: '1000',
    outstanding: '0',
    dateTime: '2024-04-30',
    paymentMethod: 'Card',
    status: 'success',
    verificationTime: '2024-04-30T10:00:00',
    offline: false,
  );

  setUp(() {
    mockService = MockVerificationService();
    mockConnectivity = MockConnectivityService();
    verificationBloc = VerificationBloc(
      service: mockService,
      connectivityService: mockConnectivity,
    );
  });

  tearDown(() {
    verificationBloc.close();
  });

  test('initial state should be VerificationInitial', () {
    expect(verificationBloc.state, const VerificationInitial());
  });

  blocTest<VerificationBloc, VerificationState>(
    'emits [VerificationLoading, VerificationSuccess] when online verification is successful',
    build: () {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => true);
      when(() => mockService.verifyOnline(any())).thenAnswer((_) async => tReceipt);
      return verificationBloc;
    },
    act: (bloc) => bloc.add(const VerifyReceiptEvent('TXN123')),
    expect: () => [
      const VerificationLoading(),
      VerificationSuccess(tReceipt),
    ],
    verify: (_) {
      verify(() => mockConnectivity.checkConnectivity()).called(1);
      verify(() => mockService.verifyOnline('TXN123')).called(1);
    },
  );

  blocTest<VerificationBloc, VerificationState>(
    'emits [VerificationLoading, VerificationSuccess] when offline verification is successful',
    build: () {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => false);
      when(() => mockService.verifyOffline(any())).thenAnswer((_) async => tReceipt);
      return verificationBloc;
    },
    act: (bloc) => bloc.add(const VerifyReceiptEvent('TXN123')),
    expect: () => [
      const VerificationLoading(),
      VerificationSuccess(tReceipt),
    ],
    verify: (_) {
      verify(() => mockConnectivity.checkConnectivity()).called(1);
      verify(() => mockService.verifyOffline('TXN123')).called(1);
    },
  );

  blocTest<VerificationBloc, VerificationState>(
    'emits [VerificationLoading, VerificationError] when verification fails',
    build: () {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => true);
      when(() => mockService.verifyOnline(any())).thenThrow(Exception('Not found'));
      return verificationBloc;
    },
    act: (bloc) => bloc.add(const VerifyReceiptEvent('TXN123')),
    expect: () => [
      const VerificationLoading(),
      const VerificationError('Not found'),
    ],
  );
}

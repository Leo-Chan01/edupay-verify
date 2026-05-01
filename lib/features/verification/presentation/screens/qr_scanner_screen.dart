import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/core/services/snackbar_service.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_event.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_state.dart';
import 'package:edupay_verify/features/verification/presentation/widgets/scanner_overlay_widget.dart';
import 'package:edupay_verify/features/verification/presentation/widgets/scanner_instructions_widget.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _handleQRCodeDetected(Barcode barcode) {
    final scannedValue = barcode.rawValue;

    if (scannedValue == null) {
      SnackbarService.showError('Failed to scan QR code');
      return;
    }

    String receiptId = scannedValue;

    // Try to parse as JSON first
    try {
      final jsonData = _parseQRJsonData(scannedValue);
      receiptId = jsonData['receipt_id'] ?? scannedValue;
    } catch (_) {
      // If not JSON, try simple format: receipt_id:reference:timestamp
      final parts = scannedValue.split(':');
      if (parts.isNotEmpty) {
        receiptId = parts[0];
      }
    }

    context.read<VerificationBloc>().add(VerifyReceiptEvent(receiptId));
  }

  Map<String, dynamic> _parseQRJsonData(String data) {
    return {'receipt_id': data};
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<VerificationBloc, VerificationState>(
      listener: (context, state) {
        if (state is VerificationSuccess) {
          context.pop();
          context.pushNamed('verification-result');
        } else if (state is VerificationError) {
          SnackbarService.showError('Error processing QR code: ${state.message}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.scanReceiptQRCode),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _scannerController,
              errorBuilder: (context, error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.cameraAccessDenied,
                          style: textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please enable camera permissions in Settings.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  _handleQRCodeDetected(barcode);
                  break;
                }
              },
            ),
            const ScannerOverlayWidget(),
            const Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: ScannerInstructionsWidget(),
            ),
            BlocBuilder<VerificationBloc, VerificationState>(
              builder: (context, state) {
                if (state is VerificationLoading) {
                  return Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: colorScheme.primary),
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.checkingReceipt,
                              style: textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

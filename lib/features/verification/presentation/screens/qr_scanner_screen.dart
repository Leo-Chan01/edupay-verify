import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/core/services/snackbar_service.dart';
import 'package:edupay_verify/features/verification/providers/verification_provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;

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
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _handleQRCodeDetected(Barcode barcode) async {
    if (_isProcessing) return;

    _isProcessing = true;
    final scannedValue = barcode.rawValue;

    if (scannedValue == null) {
      SnackbarService.showError('Failed to scan QR code');
      _isProcessing = false;
      return;
    }

    try {
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

      if (!mounted) return;

      await ref.read(verificationProvider.notifier).verifyReceipt(receiptId);

      if (!mounted) return;

      context.pop();
      context.pushNamed('verification-result');
    } catch (e) {
      if (mounted) {
        SnackbarService.showError('Error processing QR code: $e');
        _isProcessing = false;
      }
    }
  }

  Map<String, dynamic> _parseQRJsonData(String data) {
    // This would typically use jsonDecode, but for demo we'll just handle simple cases
    return {'receipt_id': data};
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _handleQRCodeDetected(barcode);
                break;
              }
            },
          ),
          // Scanner overlay
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            margin: const EdgeInsets.all(50),
          ),
          // Instructions
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppStrings.pointCameraAtQR,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Processing overlay
          if (_isProcessing)
            Container(
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
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/core/services/snackbar_service.dart';
import 'package:edupay_verify/features/dashboard/presentation/widgets/welcome_card.dart';
import 'package:edupay_verify/features/dashboard/presentation/widgets/verification_method_card.dart';
import 'package:edupay_verify/features/auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback? onQRScanTap;
  final VoidCallback? onManualSearchTap;

  const HomeScreen({
    super.key,
    this.onQRScanTap,
    this.onManualSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final adminName = authState.admin?.name ?? 'Admin';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          WelcomeCard(adminName: adminName),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: VerificationMethodCard(
                  icon: HugeIcons.strokeRoundedQrCode,
                  title: AppStrings.scanQRCode,
                  description: AppStrings.scanQRCodeDesc,
                  onTap: onQRScanTap ?? () {
                    SnackbarService.showInfo('QR Scanner - Coming soon');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: VerificationMethodCard(
                  icon: HugeIcons.strokeRoundedSearch01,
                  title: AppStrings.manualSearch,
                  description: AppStrings.manualSearchDesc,
                  onTap: onManualSearchTap ?? () {
                    SnackbarService.showInfo('Manual Search - Coming soon');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

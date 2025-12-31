import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/core/services/snackbar_service.dart';
import 'package:edupay_verify/shared/widgets/app_button.dart';
import 'package:edupay_verify/shared/widgets/app_text_field.dart';
import 'package:edupay_verify/features/verification/providers/verification_provider.dart';

class ManualSearchScreen extends ConsumerStatefulWidget {
  const ManualSearchScreen({super.key});

  @override
  ConsumerState<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends ConsumerState<ManualSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      SnackbarService.showWarning(AppStrings.pleaseEnterReceiptID);
      return;
    }

    await ref.read(verificationProvider.notifier).verifyReceipt(query);

    if (!mounted) return;

    context.pop();
    context.pushNamed('verification-result');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final verificationAsync = ref.watch(verificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manualSearch),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.enterReceiptID, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Search by receipt ID, reference, or student ID',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: AppStrings.receiptValid,
              hint: 'e.g., RCPT-1234567890',
              controller: _searchController,
              onSubmitted: (_) => _handleSearch(),
              prefixIcon: const Icon(HugeIcons.strokeRoundedSearch01),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: AppStrings.search,
              onPressed: _handleSearch,
              isLoading: verificationAsync.isLoading,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search Tips', style: textTheme.labelLarge),
                    const SizedBox(height: 12),
                    _buildSearchTip(
                      'Receipt ID',
                      'The unique transaction ID (e.g., RCPT-...)',
                    ),
                    const SizedBox(height: 8),
                    _buildSearchTip(
                      'Reference Code',
                      'The payment reference number (e.g., EOCNS/24/...)',
                    ),
                    const SizedBox(height: 8),
                    _buildSearchTip('Student ID', 'The student\'s ID number'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTip(String title, String description) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          HugeIcons.strokeRoundedCheckmarkCircle02,
          size: 20,
          color: colorScheme.secondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.labelMedium),
              Text(description, style: textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

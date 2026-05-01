import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/core/services/snackbar_service.dart';
import 'package:edupay_verify/shared/widgets/app_button.dart';
import 'package:edupay_verify/shared/widgets/app_text_field.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_event.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_state.dart';
import 'package:edupay_verify/features/verification/presentation/widgets/search_tip_widget.dart';

class ManualSearchScreen extends StatefulWidget {
  const ManualSearchScreen({super.key});

  @override
  State<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends State<ManualSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      SnackbarService.showWarning(AppStrings.pleaseEnterReceiptID);
      return;
    }

    context.read<VerificationBloc>().add(VerifyReceiptEvent(query));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<VerificationBloc, VerificationState>(
      listener: (context, state) {
        if (state is VerificationSuccess) {
          context.pop();
          context.pushNamed('verification-result');
        } else if (state is VerificationError) {
          SnackbarService.showError(state.message);
        }
      },
      child: Scaffold(
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
                AppStrings.manualSearchDesc,
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: AppStrings.transactionID,
                hint: 'e.g., TXN12345678901234',
                controller: _searchController,
                onSubmitted: (_) => _handleSearch(),
                prefixIcon: const Icon(HugeIcons.strokeRoundedSearch01),
              ),
              const SizedBox(height: 24),
              BlocBuilder<VerificationBloc, VerificationState>(
                builder: (context, state) {
                  return AppButton(
                    text: AppStrings.search,
                    onPressed: _handleSearch,
                    isLoading: state is VerificationLoading,
                  );
                },
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
                      const SearchTipWidget(
                        title: AppStrings.transactionID,
                        description: 'The unique transaction ID (e.g., TXN...)',
                      ),
                      const SizedBox(height: 8),
                      const SearchTipWidget(
                        title: 'Reference Code',
                        description: 'The payment reference number (e.g., EOCNS/24/...)',
                      ),
                      const SizedBox(height: 8),
                      const SearchTipWidget(
                        title: 'Student ID',
                        description: 'The student\'s ID number',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

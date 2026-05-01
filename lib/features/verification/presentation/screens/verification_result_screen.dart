import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_event.dart';
import 'package:edupay_verify/features/verification/presentation/bloc/verification_state.dart';
import 'package:edupay_verify/features/history/presentation/bloc/history_bloc.dart';
import 'package:edupay_verify/features/history/presentation/bloc/history_event.dart';
import 'package:edupay_verify/features/verification/presentation/widgets/receipt_header_card.dart';
import 'package:edupay_verify/features/verification/presentation/widgets/student_info_card.dart';
import 'package:edupay_verify/features/verification/presentation/widgets/receipt_details_grid.dart';
import 'package:edupay_verify/shared/widgets/loading_overlay.dart';

class VerificationResultScreen extends StatelessWidget {
  const VerificationResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyReceipt),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<VerificationBloc>().add(const ClearReceiptEvent());
            context.pop();
          },
        ),
      ),
      body: BlocBuilder<VerificationBloc, VerificationState>(
        builder: (context, state) {
          if (state is VerificationLoading) {
            return const LoadingOverlay(message: AppStrings.checkingReceipt);
          }

          if (state is VerificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    HugeIcons.strokeRoundedAlertCircle,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      state.message,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (state is VerificationSuccess) {
            final receipt = state.receipt;

            // Add to history when receipt is displayed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<HistoryBloc>().add(AddToHistoryEvent(receipt));
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReceiptHeaderCard(receipt: receipt),
                  const SizedBox(height: 16),
                  StudentInfoCard(receipt: receipt),
                  const SizedBox(height: 16),
                  ReceiptDetailsGrid(receipt: receipt),
                  const SizedBox(height: 16),
                  if (receipt.remarks != null && receipt.remarks!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.remarks,
                              style: textTheme.labelMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(receipt.remarks!, style: textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  HugeIcons.strokeRoundedQuestion,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.pleaseEnterReceiptID,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

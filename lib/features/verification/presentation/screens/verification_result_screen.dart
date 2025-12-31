import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/features/verification/providers/verification_provider.dart';
import 'package:edupay_verify/features/history/providers/history_provider.dart';
import 'package:edupay_verify/shared/widgets/loading_overlay.dart';

class VerificationResultScreen extends ConsumerWidget {
  const VerificationResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationAsync = ref.watch(verificationProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyReceipt),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(verificationProvider.notifier).clearReceipt();
            context.pop();
          },
        ),
      ),
      body: verificationAsync.when(
        data: (receipt) {
          if (receipt == null) {
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
          }

          final isValid = receipt.isValid;
          final statusColor = isValid
              ? colorScheme.secondary
              : colorScheme.error;
          final statusLabel = isValid
              ? AppStrings.receiptValid
              : AppStrings.receiptInvalid;

          // Add to history when receipt is displayed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(historyProvider.notifier).addToHistory(receipt);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receipt Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.transactionID,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    receipt.transactionId,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                statusLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Student Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primaryContainer,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              receipt.studentName[0].toUpperCase(),
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                receipt.studentName,
                                style: textTheme.labelLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                receipt.studentId,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Receipt Details Grid
                _buildDetailsGrid(context, receipt),
                const SizedBox(height: 16),

                // Remarks
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
        },
        loading: () => LoadingOverlay(message: AppStrings.checkingReceipt),
        error: (error, stack) {
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
                    error.toString(),
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
        },
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context, dynamic receipt) {
    return Column(
      children: [
        _buildDetailCard(context, [
          (AppStrings.program, receipt.program),
          (AppStrings.session, receipt.session),
        ]),
        const SizedBox(height: 12),
        _buildDetailCard(context, [
          (AppStrings.description, receipt.description),
          (AppStrings.paymentType, receipt.paymentType),
        ]),
        const SizedBox(height: 12),
        _buildDetailCard(context, [
          (AppStrings.amount, receipt.amount),
          (AppStrings.totalPaid, receipt.feesTotalPaid),
        ]),
        const SizedBox(height: 12),
        _buildDetailCard(context, [
          (AppStrings.outstanding, receipt.outstanding),
          (AppStrings.paymentMethod, receipt.paymentMethod),
        ]),
        const SizedBox(height: 12),
        _buildDetailCard(context, [
          (AppStrings.dateTime, receipt.dateTime),
          (AppStrings.status, receipt.status),
        ]),
      ],
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    List<(String, String)> details,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(details.length, (index) {
            final (label, value) = details[index];
            final isLast = index == details.length - 1;

            return Column(
              children: [
                _buildDetailRow(context, label, value),
                if (!isLast) ...[
                  const SizedBox(height: 12),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(value, style: textTheme.labelMedium, textAlign: TextAlign.end),
      ],
    );
  }
}

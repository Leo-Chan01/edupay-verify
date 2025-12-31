import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/features/history/providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final history = ref.watch(historyProvider);

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(AppStrings.noHistoryYet, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              AppStrings.noHistoryDesc,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () {
                ref.read(historyProvider.notifier).clearHistory();
              },
              child: const Text(AppStrings.clearHistory),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.verificationHistory,
                  style: textTheme.titleLarge,
                ),
                FilledButton.tonal(
                  onPressed: () {
                    ref.read(historyProvider.notifier).clearHistory();
                  },
                  child: const Text(AppStrings.clearHistory),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...history.map((item) {
              final isValid = item.status.toLowerCase() == 'success';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.transactionId,
                              style: textTheme.labelMedium?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isValid
                                          ? colorScheme.secondary
                                          : colorScheme.error)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.status.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                color: isValid
                                    ? colorScheme.secondary
                                    : colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(item.studentName, style: textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Text(
                        item.studentId,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.amount, style: textTheme.labelMedium),
                          Text(
                            item.dateTime,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

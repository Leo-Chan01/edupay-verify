import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/core/services/snackbar_service.dart';
import 'package:edupay_verify/features/offline/providers/offline_provider.dart';
import 'package:edupay_verify/features/offline/presentation/widgets/date_range_selector.dart';
import 'package:edupay_verify/features/offline/presentation/widgets/offline_stats_card.dart';

class OfflineScreen extends ConsumerStatefulWidget {
  const OfflineScreen({super.key});

  @override
  ConsumerState<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends ConsumerState<OfflineScreen> {
  bool _isDownloading = false;

  Future<void> _handleDownload(DateTime? dateFrom, DateTime? dateTo) async {
    setState(() => _isDownloading = true);

    try {
      final recordCount = await ref
          .read(offlineProvider.notifier)
          .downloadOfflineData(dateFrom: dateFrom, dateTo: dateTo);

      if (mounted) {
        SnackbarService.showSuccess(
          '$recordCount ${AppStrings.recordsDownloaded}',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _handleDeleteData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.offlineManagement),
        content: const Text(AppStrings.deleteAllOfflineRecords),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(offlineProvider.notifier).clearOfflineData();
      if (mounted) {
        SnackbarService.showSuccess(AppStrings.offlineDataDeleted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final offlineData = ref.watch(offlineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.offlineManagement)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Section
                if (offlineData != null)
                  OfflineStatsCard(
                    recordCount: offlineData.recordCount,
                    lastUpdated: offlineData.downloadedAt,
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppStrings.noOfflineDataAvailable,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Download Section
                if (!_isDownloading) ...[
                  Text(AppStrings.downloadRecords, style: textTheme.titleSmall),
                  const SizedBox(height: 12),
                  DateRangeSelector(onDatesSelected: _handleDownload),
                ],

                // Management Section
                if (offlineData != null && !_isDownloading) ...[
                  const SizedBox(height: 24),
                  Text('Management', style: textTheme.titleSmall),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: _handleDeleteData,
                      style: FilledButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                      child: const Text(AppStrings.delete),
                    ),
                  ),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
          // Loading Overlay
          if (_isDownloading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.downloadingRecords,
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

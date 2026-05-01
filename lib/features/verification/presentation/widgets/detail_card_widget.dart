import 'package:flutter/material.dart';
import 'detail_row_widget.dart';

class DetailCardWidget extends StatelessWidget {
  final List<(String, String)> details;

  const DetailCardWidget({
    required this.details,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(details.length, (index) {
            final (label, value) = details[index];
            final isLast = index == details.length - 1;

            return Column(
              children: [
                DetailRowWidget(label: label, value: value),
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
}

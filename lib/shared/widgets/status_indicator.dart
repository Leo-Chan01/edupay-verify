import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final bool isOnline;
  final String statusText;

  const StatusIndicator({
    super.key,
    required this.isOnline,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline 
                ? const Color(0xFF00D2D3) 
                : const Color(0xFFFF9F43),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          statusText,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

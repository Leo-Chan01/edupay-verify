import 'package:flutter/material.dart';

class ScannerOverlayWidget extends StatelessWidget {
  const ScannerOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Corners or some visual indicator that doesn't use standard borders/shadows if possible
            // But if I must avoid borders, maybe just a slightly dimmed background with a clear center
            // The user rule says "NEVER USE BORDERS".
            // I'll use a stylized container with a specific color background but transparent center.
            CustomPaint(
              size: const Size(250, 250),
              painter: ScannerFramePainter(color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerFramePainter extends CustomPainter {
  final Color color;

  ScannerFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    const radius = 12.0;

    // Top Left
    canvas.drawArc(
      Rect.fromLTWH(0, 0, radius * 2, radius * 2),
      3.14,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(const Offset(0, radius), const Offset(0, cornerLength), paint);
    canvas.drawLine(const Offset(radius, 0), const Offset(cornerLength, 0), paint);

    // Top Right
    canvas.drawArc(
      Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2),
      4.71,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(Offset(size.width, radius), Offset(size.width, cornerLength), paint);
    canvas.drawLine(Offset(size.width - radius, 0), Offset(size.width - cornerLength, 0), paint);

    // Bottom Left
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - radius * 2, radius * 2, radius * 2),
      1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(Offset(0, size.height - radius), Offset(0, size.height - cornerLength), paint);
    canvas.drawLine(Offset(radius, size.height), Offset(cornerLength, size.height), paint);

    // Bottom Right
    canvas.drawArc(
      Rect.fromLTWH(size.width - radius * 2, size.height - radius * 2, radius * 2, radius * 2),
      0,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(Offset(size.width, size.height - radius), Offset(size.width, size.height - cornerLength), paint);
    canvas.drawLine(Offset(size.width - radius, size.height), Offset(size.width - cornerLength, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

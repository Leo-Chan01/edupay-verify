import 'package:flutter/material.dart';

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    _showSnackbar(
      message,
      backgroundColor: const Color(0xFF00B894),
      icon: Icons.check_circle,
    );
  }

  static void showError(String message) {
    _showSnackbar(
      message,
      backgroundColor: const Color(0xFFD63031),
      icon: Icons.error,
    );
  }

  static void showWarning(String message) {
    _showSnackbar(
      message,
      backgroundColor: const Color(0xFFFDCB6E),
      textColor: const Color(0xFF2D3436),
      icon: Icons.warning,
    );
  }

  static void showInfo(String message) {
    _showSnackbar(
      message,
      backgroundColor: const Color(0xFF6C5CE7),
      icon: Icons.info,
    );
  }

  static void _showSnackbar(
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Color textColor = Colors.white,
  }) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

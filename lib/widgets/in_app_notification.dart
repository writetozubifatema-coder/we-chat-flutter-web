import 'package:flutter/material.dart';

void showWebInAppNotification({
  required BuildContext context,
  required String senderName,
  required String message,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      backgroundColor: Colors.black,
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          const Icon(Icons.message, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$senderName: $message',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

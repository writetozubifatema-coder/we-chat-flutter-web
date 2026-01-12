import 'package:flutter/material.dart';

class Dialogs {
  static void showsnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color.fromRGBO(33, 150, 243, 0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showprogressbar(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true, // ⭐ IMPORTANT
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
}

}
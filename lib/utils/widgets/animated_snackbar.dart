import 'package:flutter/material.dart';

class AnimatedSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.green,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
      behavior: behavior,
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

import 'package:flutter/material.dart';

class ShowSnackbar {
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(message)),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.transparent,
    ));
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(message)),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.transparent,
    ));
  }
}

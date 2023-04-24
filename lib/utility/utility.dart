import 'package:flutter/material.dart';

class Utility {
  static showSnackbar({
    required String text,
    required BuildContext context,
    Color? color,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: color ?? Colors.green,
    ));
  }
}

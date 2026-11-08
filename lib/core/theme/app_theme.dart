import 'package:flutter/material.dart';

class AppTheme {
  static const Color navy = Color(0xFF082B50);
  static const Color gold = Color(0xFFE5A93C);
  static const Color goldDeep = Color(0xFFC78B24);
  static const Color paper = Color(0xFFF7FAFC);
  static const Color line = Color(0xFFE2E8F0);
  static const Color green = Color(0xFF1B8755);
  static const Color red = Color(0xFFD32F2F);

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label.isNotEmpty ? label : null,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: navy, width: 1.5),
      ),
    );
  }
}

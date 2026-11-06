import 'package:flutter/material.dart';

Widget authField(
    String label,
    TextEditingController controller, {
      bool hidden = false,
    }) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          obscureText: hidden,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE9E9E9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    ),
  );
}

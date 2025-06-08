import 'package:flutter/material.dart';

class CustumTextFeilds extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  CustumTextFeilds({Key? key, required this.controller, required this.hintText})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: const Color(0xffF5F5FA),
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
    );
  }
}

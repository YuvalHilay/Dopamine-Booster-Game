import 'package:flutter/material.dart';

// Custom text field widget
class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final String? errorMsg;
  final String? Function(String?)? onChanged;

  // Constructor with required and optional parameters.
  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.keyboardType,
      this.suffixIcon,
      this.onTap,
      this.prefixIcon,
      this.validator,
      this.focusNode,
      this.errorMsg,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      focusNode: focusNode,
      onTap: onTap,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      style: TextStyle(
        color: Theme.of(context)
            .colorScheme
            .inversePrimary, // Set the input text color
      ),
      decoration: InputDecoration(
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.inversePrimary,
              width: 3,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.onPrimary,
          hintText: hintText,
          hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary, // Adjust hint text color here
        ),
          errorText: errorMsg,
          errorStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          )),
    );
  }
}

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Text field with a label above it and an icon inside, as in the design forms.
class LabeledTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final String? helperText;
  final String? hintText;
  final int? maxLength;
  final bool isHighlighted;
  final ValueChanged<String>? onChanged;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffix,
    this.helperText,
    this.hintText,
    this.maxLength,
    this.isHighlighted = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLength: maxLength,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 22),
            suffixIcon: suffix,
            helperText: helperText,
            hintText: hintText,
            helperMaxLines: 2,
            errorMaxLines: 2,
            errorStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            enabledBorder: isHighlighted
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.honey, width: 2),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

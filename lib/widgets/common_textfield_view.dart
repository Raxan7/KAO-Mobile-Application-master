import 'package:flutter/material.dart';

class CommonTextFieldView extends StatelessWidget {
  final String titleText;
  final String hintText;
  final String? errorText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isObscureText;
  final ValueChanged<String> onChanged;

  const CommonTextFieldView({super.key, 
    required this.titleText,
    required this.hintText,
    this.errorText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isObscureText = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isObscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

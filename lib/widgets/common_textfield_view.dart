import 'package:flutter/material.dart';

class CommonTextFieldView extends StatelessWidget {
  final String titleText;
  final String hintText;
  final String? errorText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isObscureText;
  final ValueChanged<String> onChanged;
  final bool isDesktop;

  const CommonTextFieldView({
    super.key, 
    required this.titleText,
    required this.hintText,
    this.errorText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isObscureText = false,
    required this.onChanged,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = isDesktop ? 32.0 : 24.0;
    final verticalPadding = isDesktop ? 12.0 : 10.0;
    final titleFontSize = isDesktop ? 18.0 : 14.0;
    final hintFontSize = isDesktop ? 16.0 : 14.0;
    final borderRadius = isDesktop ? 12.0 : 10.0;
    final contentPadding = isDesktop 
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 16);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isDesktop ? 12.0 : 8.0),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isObscureText,
            onChanged: onChanged,
            style: TextStyle(fontSize: hintFontSize),
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
              hintStyle: TextStyle(fontSize: hintFontSize),
              contentPadding: contentPadding,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

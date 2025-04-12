import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;
  final bool isDesktop;

  const CommonButton({
    super.key, 
    required this.buttonText, 
    required this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = isDesktop ? 32.0 : 24.0;
    final verticalPadding = isDesktop ? 12.0 : 10.0;
    final buttonPadding = isDesktop 
        ? const EdgeInsets.symmetric(vertical: 16.0)
        : const EdgeInsets.symmetric(vertical: 14.0);
    final borderRadius = isDesktop ? 12.0 : 10.0;
    final fontSize = isDesktop ? 18.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 2,
            shadowColor: Theme.of(context).shadowColor,
          ),
          child: Text(
            buttonText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

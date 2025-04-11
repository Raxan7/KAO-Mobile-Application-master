import 'package:flutter/material.dart';

class BookingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BookingButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Book Now'),
    );
  }
}

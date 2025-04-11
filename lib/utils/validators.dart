class Validators {
  // Enhanced Email Validation
  static String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null; // Return null if validation passes
  }

  // Simplified Password Validation
  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters long';
    }
    return null; // Return null if validation passes
  }

  // Other validation methods remain unchanged...
}

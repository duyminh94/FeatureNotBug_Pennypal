class Validators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isEmpty(String? value) => (value ?? '').trim().isEmpty;

  static bool isValidEmail(String? value) => _emailPattern.hasMatch((value ?? '').trim());
}

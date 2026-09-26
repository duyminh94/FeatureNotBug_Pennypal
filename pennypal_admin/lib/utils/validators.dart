/// Checks used by the admin forms.
class Validators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// True when the field is empty or only has spaces.
  static bool isEmpty(String? value) => (value ?? '').trim().isEmpty;

  /// Simple email shape check: something@something.domain.
  static bool isValidEmail(String? value) => _emailPattern.hasMatch((value ?? '').trim());
}

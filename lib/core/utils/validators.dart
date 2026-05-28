/// Form field validators.
/// All return null (valid) or a String error message (invalid).
/// Used directly in TextFormField's validator parameter.
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required.';
    if (value.trim().length < 2) return 'Name must be at least 2 characters.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 15) return 'Enter a valid phone number.';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required.';
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    if (value == null || value.trim().length < min) {
      return '$fieldName must be at least $min characters.';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'Price is required.';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid price.';
    if (parsed < 0) return 'Price cannot be negative.';
    return null;
  }

  static String? stock(String? value) {
    if (value == null || value.trim().isEmpty) return 'Stock quantity is required.';
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Enter a whole number.';
    if (parsed < 0) return 'Stock cannot be negative.';
    return null;
  }
}

extension StringX on String {
  /// "hello world" → "Hello World"
  String get toTitleCase {
    if (isEmpty) return this;
    return split(' ')
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// "hello" → "Hello"
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncates to [maxLength] and appends '…' if longer.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }

  /// Returns true if the string is a valid email address.
  bool get isValidEmail {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(this);
  }

  /// Returns null if empty, the string itself otherwise.
  String? get nullIfEmpty => isEmpty ? null : this;

  /// Strips all whitespace.
  String get stripped => replaceAll(RegExp(r'\s+'), '');
}

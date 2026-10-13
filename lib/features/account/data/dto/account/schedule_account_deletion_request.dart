class ScheduleAccountDeletionRequest {
  const ScheduleAccountDeletionRequest({
    this.password,
    this.code,
    required this.confirm,
  });

  final String? password;
  final String? code;
  final String confirm;

  Map<String, dynamic> toJson() {
    final normalizedPassword = _optional(password, trim: false);
    final normalizedCode = _optional(code);
    if (normalizedPassword == null && normalizedCode == null) {
      throw ArgumentError('Provide your password or deletion code.');
    }
    if (normalizedCode != null &&
        !RegExp(r'^\d{6}$').hasMatch(normalizedCode)) {
      throw ArgumentError.value(
        code,
        'code',
        'Deletion code must contain exactly 6 digits.',
      );
    }
    if (confirm.trim() != 'DELETE') {
      throw ArgumentError.value(
        confirm,
        'confirm',
        'Type DELETE to confirm account deletion.',
      );
    }
    return {
      'password': ?normalizedPassword,
      'code': ?normalizedCode,
      'confirm': 'DELETE',
    };
  }
}

String? _optional(String? value, {bool trim = true}) {
  final normalized = trim ? value?.trim() : value;
  return normalized == null || normalized.isEmpty ? null : normalized;
}

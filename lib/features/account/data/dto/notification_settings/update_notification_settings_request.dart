class UpdateNotificationSettingsRequest {
  const UpdateNotificationSettingsRequest({
    this.channelInApp,
    this.channelEmail,
    this.quietHoursEnabled,
    this.quietHoursFrom,
    this.quietHoursTo,
  });

  final bool? channelInApp;
  final bool? channelEmail;
  final bool? quietHoursEnabled;
  final String? quietHoursFrom;
  final String? quietHoursTo;

  bool get hasChanges =>
      channelInApp != null ||
      channelEmail != null ||
      quietHoursEnabled != null ||
      quietHoursFrom != null ||
      quietHoursTo != null;

  Map<String, dynamic> toJson() {
    if (!hasChanges) {
      throw ArgumentError(
        'At least one notification setting must be supplied.',
      );
    }
    _validateTime('quietHoursFrom', quietHoursFrom);
    _validateTime('quietHoursTo', quietHoursTo);
    return {
      if (channelInApp != null) 'channelInApp': channelInApp,
      if (channelEmail != null) 'channelEmail': channelEmail,
      if (quietHoursEnabled != null) 'quietHoursEnabled': quietHoursEnabled,
      if (quietHoursFrom != null) 'quietHoursFrom': quietHoursFrom,
      if (quietHoursTo != null) 'quietHoursTo': quietHoursTo,
    };
  }
}

void _validateTime(String field, String? value) {
  if (value == null) return;
  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
  final hour = match == null ? null : int.tryParse(match.group(1)!);
  final minute = match == null ? null : int.tryParse(match.group(2)!);
  if (hour == null || minute == null || hour > 23 || minute > 59) {
    throw ArgumentError.value(value, field, 'Use a valid 24-hour HH:mm time.');
  }
}

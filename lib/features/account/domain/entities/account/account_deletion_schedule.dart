class AccountDeletionSchedule {
  const AccountDeletionSchedule({required this.deletionScheduledAt});

  factory AccountDeletionSchedule.fromJson(Map<String, dynamic> json) {
    final value = json['deletionScheduledAt']?.toString() ?? '';
    final date = DateTime.tryParse(value);
    if (date == null) {
      throw const FormatException('Invalid account deletion schedule.');
    }
    return AccountDeletionSchedule(deletionScheduledAt: date);
  }

  final DateTime deletionScheduledAt;
}

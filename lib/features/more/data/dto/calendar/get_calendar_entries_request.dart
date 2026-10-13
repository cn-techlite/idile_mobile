class GetCalendarEntriesRequest {
  const GetCalendarEntriesRequest({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  Map<String, String> toQueryParameters() {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    if (start.isAfter(end)) {
      throw ArgumentError.value(
        to,
        'to',
        'The end date cannot be before the start date.',
      );
    }
    return {'from': _date(start), 'to': _date(end)};
  }
}

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

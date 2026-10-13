class CalendarFeedToken {
  const CalendarFeedToken({this.url});

  factory CalendarFeedToken.fromJson(Map<String, dynamic> json) {
    final value = json['url']?.toString().trim();
    return CalendarFeedToken(
      url: value == null || value.isEmpty ? null : value,
    );
  }

  final String? url;
}

class AccountDataExport {
  const AccountDataExport({required this.data});

  factory AccountDataExport.fromJson(Map<String, dynamic> json) =>
      AccountDataExport(data: Map.unmodifiable(json));

  final Map<String, dynamic> data;

  DateTime? get exportedAt =>
      DateTime.tryParse(data['exportedAt']?.toString() ?? '');

  Map<String, dynamic> get account => _map(data['account']);
  List<Map<String, dynamic>> get spaces => _list(data['spaces']);
  List<Map<String, dynamic>> get categories => _list(data['categories']);
  List<Map<String, dynamic>> get currencies => _list(data['currencies']);
  List<Map<String, dynamic>> get bills => _list(data['bills']);
  List<Map<String, dynamic>> get subscriptions => _list(data['subscriptions']);
  List<Map<String, dynamic>> get householdItems =>
      _list(data['householdItems']);
  List<Map<String, dynamic>> get maintenanceTasks =>
      _list(data['maintenanceTasks']);
  List<Map<String, dynamic>> get assets => _list(data['assets']);
  List<Map<String, dynamic>> get documents => _list(data['documents']);
  List<Map<String, dynamic>> get notifications => _list(data['notifications']);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

List<Map<String, dynamic>> _list(Object? value) => (value as List? ?? const [])
    .whereType<Map>()
    .map(Map<String, dynamic>.from)
    .toList(growable: false);

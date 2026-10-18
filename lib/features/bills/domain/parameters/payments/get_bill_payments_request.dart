class GetBillPaymentsRequest {
  const GetBillPaymentsRequest({this.spaceId, this.billId});

  final String? spaceId;
  final String? billId;

  Map<String, String> toQueryParameters() {
    final query = <String, String>{};
    final normalizedSpaceId = _optional(spaceId);
    if (normalizedSpaceId != null) query['spaceId'] = normalizedSpaceId;
    final normalizedBillId = _optional(billId);
    if (normalizedBillId != null) query['billId'] = normalizedBillId;
    return query;
  }
}

String? _optional(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

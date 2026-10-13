import 'package:idile_mobile_app/features/more/data/dto/documents/create_document_request.dart';

class UpdateDocumentRequest {
  const UpdateDocumentRequest({
    this.title,
    this.spaceId,
    this.type,
    this.expiry,
    this.related,
    this.householdItemId,
    this.assetId,
    this.status,
  });

  final String? title;
  final String? spaceId;
  final String? type;
  final String? expiry;
  final String? related;
  final String? householdItemId;
  final String? assetId;
  final String? status;

  Map<String, dynamic> toJson() {
    if (title == null &&
        spaceId == null &&
        type == null &&
        expiry == null &&
        related == null &&
        householdItemId == null &&
        assetId == null &&
        status == null) {
      throw ArgumentError('At least one document field must be supplied.');
    }
    final json = <String, dynamic>{};
    if (title != null) {
      json['title'] = requiredDocumentText(title!, 'title', 'Document title');
    }
    if (spaceId != null) {
      json['spaceId'] = requiredDocumentText(spaceId!, 'spaceId', 'Space id');
    }
    if (type != null) json['type'] = documentType(type!);
    if (expiry != null) {
      json['expiry'] = optionalDocumentDate(expiry!, 'expiry');
    }
    if (related != null) json['related'] = related!.trim();
    if (householdItemId != null) {
      json['householdItemId'] = householdItemId!.trim();
    }
    if (assetId != null) json['assetId'] = assetId!.trim();
    if (status != null) json['status'] = _status(status!);
    return json;
  }
}

String _status(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized != 'active' && normalized != 'expiring') {
    throw ArgumentError.value(
      value,
      'status',
      'Status must be active or expiring.',
    );
  }
  return normalized;
}

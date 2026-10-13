import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/more/data/dto/documents/create_document_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/documents/get_documents_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/documents/update_document_request.dart';
import 'package:idile_mobile_app/features/more/data/model/documents/document_item.dart';

class DocumentRemoteService {
  const DocumentRemoteService(this._api);

  final ApiClient _api;

  Future<DocumentPage> documents(GetDocumentsRequest request) {
    final uri = Uri(
      path: Endpoints.documentsUrl,
      queryParameters: request.toQueryParameters(),
    );
    return _api.getEnvelope(
      uri.toString(),
      (value) =>
          DocumentPage.fromEnvelope(Map<String, dynamic>.from(value as Map)),
    );
  }

  Future<DocumentItem> document(String documentId) => _api.get(
    Endpoints.documentUrl(_validId(documentId)),
    (value) => DocumentItem.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<DocumentItem> createDocument(CreateDocumentRequest request) =>
      _api.multipart(
        Endpoints.documentsUrl,
        (value) =>
            DocumentItem.fromJson(Map<String, dynamic>.from(value as Map)),
        fields: request.toFields(),
        fileBytes: request.fileBytes,
        fileName: request.fileName?.trim(),
      );

  Future<DocumentItem> updateDocument(
    String documentId,
    UpdateDocumentRequest request,
  ) => _api.patch(
    Endpoints.documentUrl(_validId(documentId)),
    (value) => DocumentItem.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<bool> deleteDocument(String documentId) => _api.delete(
    Endpoints.documentUrl(_validId(documentId)),
    (value) => value is Map && value['deleted'] == true,
  );

  String _validId(String value) {
    final id = value.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(
        value,
        'documentId',
        'Document id cannot be empty.',
      );
    }
    return id;
  }
}

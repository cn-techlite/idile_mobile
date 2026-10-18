import 'package:idile_mobile_app/features/more/domain/entities/documents/document_item.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/documents/create_document_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/documents/get_documents_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/documents/update_document_request.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/documents/document_repository.dart';

final class DocumentUseCases {
  const DocumentUseCases(this._repository);

  final DocumentRepository _repository;

  Future<DocumentPage> documents(GetDocumentsRequest request) =>
      _repository.documents(request);

  Future<DocumentItem> document(String documentId) =>
      _repository.document(documentId);

  Future<DocumentItem> createDocument(CreateDocumentRequest request) =>
      _repository.createDocument(request);

  Future<DocumentItem> updateDocument(
    String documentId,
    UpdateDocumentRequest request,
  ) => _repository.updateDocument(documentId, request);

  Future<bool> deleteDocument(String documentId) =>
      _repository.deleteDocument(documentId);
}

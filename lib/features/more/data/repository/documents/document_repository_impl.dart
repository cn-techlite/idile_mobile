import 'package:idile_mobile_app/features/more/domain/parameters/documents/create_document_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/documents/get_documents_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/documents/update_document_request.dart';
import 'package:idile_mobile_app/features/more/domain/entities/documents/document_item.dart';
import 'package:idile_mobile_app/features/more/data/service/documents/document_remote_service.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/documents/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  const DocumentRepositoryImpl(this._remoteService);

  final DocumentRemoteService _remoteService;

  @override
  Future<DocumentPage> documents(GetDocumentsRequest request) =>
      _remoteService.documents(request);

  @override
  Future<DocumentItem> document(String documentId) =>
      _remoteService.document(documentId);

  @override
  Future<DocumentItem> createDocument(CreateDocumentRequest request) =>
      _remoteService.createDocument(request);

  @override
  Future<DocumentItem> updateDocument(
    String documentId,
    UpdateDocumentRequest request,
  ) => _remoteService.updateDocument(documentId, request);

  @override
  Future<bool> deleteDocument(String documentId) =>
      _remoteService.deleteDocument(documentId);
}

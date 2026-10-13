import 'package:idile_mobile_app/features/more/data/dto/documents/create_document_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/documents/get_documents_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/documents/update_document_request.dart';
import 'package:idile_mobile_app/features/more/data/model/documents/document_item.dart';

abstract interface class DocumentRepository {
  Future<DocumentPage> documents(GetDocumentsRequest request);
  Future<DocumentItem> document(String documentId);
  Future<DocumentItem> createDocument(CreateDocumentRequest request);
  Future<DocumentItem> updateDocument(
    String documentId,
    UpdateDocumentRequest request,
  );
  Future<bool> deleteDocument(String documentId);
}

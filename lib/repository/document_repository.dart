import '../data/database/dao/document_dao.dart';
import '../data/database/models/document_model_local.dart';

class DocumentRepository {
  final DocumentDao documentDao = DocumentDao();

  Future<List<DocumentModel>> getUserDocuments(int userId) {
    return documentDao.getDocumentsByUserId(userId);
  }

  Future<void> addDocument(DocumentModel doc) {
    return documentDao.insertDocument(doc);
  }

  Future<void> deleteDocument(int docId) {
    return documentDao.deleteDocument(docId);
  }
}

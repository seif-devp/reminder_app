import '../app_database.dart';
import '../models/document_model_local.dart';

class DocumentDao {
  final db = AppDatabase.instance;

  // Add a document
  Future<int> insertDocument(DocumentModel doc) async {
    final database = await db.database;
    return database.insert("documents", doc.toMap());
  }

  // Get documents for a specific user
  Future<List<DocumentModel>> getDocumentsByUserId(int userId) async {
    final database = await db.database;

    final result = await database.query(
      "documents",
      where: "user_id = ?",
      whereArgs: [userId],
    );

    return result.map((map) => DocumentModel.fromMap(map)).toList();
  }

  // Delete a document
  Future<int> deleteDocument(int docId) async {
    final database = await db.database;
    return database.delete(
      "documents",
      where: "doc_id = ?",
      whereArgs: [docId],
    );
  }
}

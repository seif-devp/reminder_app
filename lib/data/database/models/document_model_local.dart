class DocumentModel {
  int? docId;
  int userId;
  String fileUrl;
  String fileName;

  DocumentModel({
    this.docId,
    required this.userId,
    required this.fileUrl,
    required this.fileName,
  });

  Map<String, dynamic> toMap() {
    return {
      'doc_id': docId,
      'user_id': userId,
      'file_url': fileUrl,
      'file_name': fileName,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      docId: map['doc_id'],
      userId: map['user_id'],
      fileUrl: map['file_url'],
      fileName: map['file_name'],
    );
  }
}

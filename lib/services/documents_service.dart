import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/document_model.dart';
import '../main.dart';

class DocumentsService extends GetxService {

  static const String documentBucket = 'documention';
  static const String documentsTable = 'documents'; 

  Future<String?> uploadDocument(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final docName = 'document_file/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      await cloud.storage.from(documentBucket).uploadBinary(docName, bytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            cacheControl: '3600',
          ));

      return cloud.storage.from(documentBucket).getPublicUrl(docName);
    } catch (e) {
      Get.snackbar('error uploading', 'failed to upload document: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return null;
    }
  }
  Future<Uint8List> DownloadedDocUrl(String url)
  async {
    final fullPathDecoded = Uri.decodeFull(Uri.parse(url).path);
    final startKey = '/public/$documentBucket/';
    final startindex=fullPathDecoded.indexOf(startKey);
    if (startindex == -1) {
      throw Exception('Invalid document URL: $url');
    }
    final filePath = fullPathDecoded.substring(startindex + startKey.length);

    final downloaded= await cloud.storage.from(documentBucket).download(filePath);
    return downloaded;
  }

  Future<void> deleteFileFromStorage(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      final documentBucket = 'documention';
      final segments = uri.pathSegments;

      final bucketIndex = segments.indexOf(documentBucket);

      String filePath = '';

      if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
        filePath = segments.sublist(bucketIndex + 1).join('/');
        print('Calculated Storage Path for Deletion: $filePath');

        // 4. نحذف الملف
        await cloud.storage.from(documentBucket).remove([filePath]);

      } else {
        throw Exception('Could not parse file path from URL for deletion.');
      }

    } catch (e) {
      print('Storage Error deleting file: $e');
      throw Exception('Storage file delete failed: Please check your Supabase setup or file permissions.');
    }
  }

  Future<List<Map<String, dynamic>>> getDocuments() async {
    final data = await cloud.from(documentsTable).
    select('doc_id, file_url, file_name, user_id');
    return data;
  }

  Future<void> saveDocumentMetadata(Documents document) async {
    try {
      await cloud.from(documentsTable).insert(document.toJson());
    } on PostgrestException catch (e) {
      print('Postgres Error saving document: ${e.message}');
      throw Exception('Database save failed: ${e.message}');
    }
  }

  Future<void> deleteDocumentMetadata(String docId) async {
    try {
      await cloud.from(documentsTable).delete().eq('doc_id', docId);
    } on PostgrestException catch (e) {
      print('Postgres Error deleting document: ${e.message}');
      throw Exception('Database delete failed: ${e.message}');
    }
  }

  String? getCurrentUserId() {
    return cloud.auth.currentUser?.id;
  }

}
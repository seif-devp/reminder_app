import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// 💡 نحتاج لاستيراد الملفات الخاصة بالـ Models
import '../model/document_model.dart';
import '../model/medication_model.dart';
// 💡 نحتاج إلى الوصول إلى الـ Supabase Client المُعرف في main.dart
// نفترض أن المتغير العام هو 'cloud' كما استخدمته سابقاً.
import '../main.dart';

class SupabaseService extends GetxService {

  // ----------------------------------------------------
  // 1. الثوابت (Constants)
  // ----------------------------------------------------
  static const String _medicationBucket = 'medication_image';
  static const String _medicationsTable = 'medications';
  static const String documentBucket = 'documention';
  static const String _documentsTable = 'documents'; // جدول Postgres للمستندات

  // ----------------------------------------------------
  // 2. دوال الرفع والتخزين (Storage Operations)
  // ----------------------------------------------------

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = 'medication_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';

      await cloud.storage.from(_medicationBucket).uploadBinary(fileName, bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            cacheControl: '3600',
          ));

      return cloud.storage.from(_medicationBucket).getPublicUrl(fileName);
    } catch (e) {
      Get.snackbar('خطأ في التحميل', 'فشل تحميل الصورة: $e', snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

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
      throw Exception('اسم الباكت مش موجود في رابط الملف. تأكد من الباكت أو الرابط.');
    }
    final filePath = fullPathDecoded.substring(startindex + startKey.length);

     final downloaded= await cloud.storage.from(documentBucket).download(filePath);
     return downloaded;
  }

  // 💡 دالة حذف الملف من Supabase Storage
  Future<void> deleteFileFromStorage(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      final documentBucket = 'documention';
      final segments = uri.pathSegments;

      // 💡 1. البحث عن موقع اسم الـ Bucket في الرابط (الذي يفترض أنه documentBucket)
      final bucketIndex = segments.indexOf(documentBucket);

      String filePath = '';

      // 💡 2. التحقق من وجود اسم الـ Bucket وأن لديه أجزاء تابعة (أي محتوى)
      if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
        // 💡 3. استخراج المسار الذي يلي اسم الـ Bucket مباشرةً (وهذا هو المسار المطلوب لـ .remove)
        filePath = segments.sublist(bucketIndex + 1).join('/');
        print('Calculated Storage Path for Deletion: $filePath');

        // 4. نحذف الملف
        // تأكد أن cloud يشير إلى Supabase.instance.client
        await cloud.storage.from(documentBucket).remove([filePath]);

      } else {
        // إذا لم يتم العثور على اسم الباكت بعد 'public'، فربما يكون الرابط غير صحيح
        throw Exception('Could not parse file path from URL for deletion.');
      }

    } catch (e) {
      print('Storage Error deleting file: $e');
      // لتبسيط التتبع، يفضل عدم إظهار متغير 'e' مباشرةً في رسالة المستخدم النهائية.
      throw Exception('Storage file delete failed: Please check your Supabase setup or file permissions.');
    }
  }

  // ----------------------------------------------------
  // 3. دوال قاعدة البيانات (Postgres Operations)
  // ----------------------------------------------------

  // 💡 جلب المستندات (R - Read)
  Future<List<Map<String, dynamic>>> getDocuments() async {
    //final userId = cloud.auth.currentUser?.id; // هات الـ ID بتاع اليوزر الحالي
    //if (userId == null) return []; // لو مفيش يوزر رجع ليست فاضية
    // 💡 تصحيح الاستعلام: طلب doc_id و user_id بالأسماء الصحيحة من قاعدة البيانات
    final data = await cloud.from(_documentsTable).
    select('doc_id, file_url, file_name, user_id');
    //.eq('user_id', userId);
    return data;
  }

  // 💡 حفظ بيانات المستند (C - Create/Save Metadata)
  Future<void> saveDocumentMetadata(Documents document) async {
    try {
      // نستخدم toJson() لتحويل الكائن إلى Map وإرساله لجدول Postgres
      await cloud.from(_documentsTable).insert(document.toJson());
    } on PostgrestException catch (e) {
      print('Postgres Error saving document: ${e.message}');
      throw Exception('Database save failed: ${e.message}');
    }
  }

  // 💡 حذف بيانات المستند (D - Delete Metadata)
  Future<void> deleteDocumentMetadata(String docId) async {
    try {
      // 💡 تصحيح: استخدام 'doc_id' كاسم للعمود للحذف
      await cloud.from(_documentsTable).delete().eq('doc_id', docId);
    } on PostgrestException catch (e) {
      print('Postgres Error deleting document: ${e.message}');
      throw Exception('Database delete failed: ${e.message}');
    }
  }

  // 💡 دالة إضافة دواء (Medication)
  Future<void> addMedication(Medications medication) async {
    try {
      await cloud.from(_medicationsTable).insert(medication.toJson()).select();

    } on PostgrestException catch (e) {
      Get.snackbar('خطأ في قاعدة البيانات', 'فشل إضافة الدواء: ${e.message}',
          snackPosition: SnackPosition.BOTTOM);
      throw e;
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ غير متوقع أثناء إضافة الدواء.',
          snackPosition: SnackPosition.BOTTOM);
      throw e;
    }
  }
  String? getCurrentUserId() {
    return cloud.auth.currentUser?.id;
  }

}
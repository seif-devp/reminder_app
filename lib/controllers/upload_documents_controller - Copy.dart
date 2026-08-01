import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // 📦 للتخزين المحلي
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart'; // 📂 لمسارات التخزين الداخلية

// تأكد من صحة مسارات الاستيراد
import 'package:reminder_app/model/document_model.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/services/documents_service.dart';

class UploadDocumentsController extends GetxController {

  // Services
  final DocumentsService supa = Get.find<DocumentsService>();
  final ConnectivityService connectivityService = Get.find<ConnectivityService>();

  // Storage Box
  final box = GetStorage();

  // State Variables
  final document = <Documents>[].obs;
  final isLoading = false.obs;
  final selectedFile = Rx<XFile?>(null);

  late StreamSubscription<dynamic> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();

    // 1️⃣ استرجاع البيانات القديمة فوراً (عشان الشاشة متكونش بيضا)
    loadDocumentsFromLocal();

    // 2️⃣ جلب التحديثات من السيرفر
    fetechDOCS();

    // مراقبة النت للمزامنة
    _connectivitySubscription = connectivityService.checkforInternet().listen((results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        _syncPendingUploads();
      }
    });
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  // ========================================================================
  // 💾 LOCAL STORAGE & FETCH
  // ========================================================================

  void saveDocumentsToLocal() {
    List<Map<String, dynamic>> jsonList = document.map((doc) => doc.toJson()).toList();
    box.write('cached_documents', jsonList);
  }

  void loadDocumentsFromLocal() {
    if (box.hasData('cached_documents')) {
      List<dynamic> storedList = box.read('cached_documents');
      List<Documents> localDocs = storedList.map((e) => Documents.fromJson(e)).toList();
      document.assignAll(localDocs);
    }
  }

  Future<void> fetechDOCS() async {
    if (document.isEmpty) isLoading.value = true;

    try {
      final rawData = await supa.getDocuments();
      final List<Documents> fetchedDocuments = rawData.map((json) {
        if (json.containsKey('file_url')) {
          return Documents.fromJson(json);
        }
        throw Exception("Invalid data.");
      }).toList();

      // 💡 دمج ذكي: الحفاظ على المسارات المحلية للملفات المحملة سابقاً
      final List<Documents> mergedList = [];

      for (var serverDoc in fetchedDocuments) {
        final localMatch = document.firstWhereOrNull((d) => d.docId == serverDoc.docId);

        // لو الملف كان عندنا ومساره لسه سليم، نحتفظ بيه
        if (localMatch != null && localMatch.local_direct != null) {
          final file = File(localMatch.local_direct!);
          if (file.existsSync()) {
            mergedList.add(serverDoc.copyWith(local_direct: localMatch.local_direct));
          } else {
            // لو الملف اتمسح من الجهاز، نرجع نخليه null
            mergedList.add(serverDoc.copyWith(local_direct: null));
          }
        } else {
          mergedList.add(serverDoc);
        }
      }

      document.assignAll(mergedList);
      saveDocumentsToLocal();

    } catch (e) {
      print("Error fetching: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================================================
  // 👁️ PRO VIEW LOGIC (Cache First - No Browser)
  // ========================================================================

  Future<void> viewDocument(Documents doc) async {
    File? fileToOpen;
    String? localPath = doc.local_direct;

    // 1️⃣ فحص الكاش الداخلي
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (await file.exists()) {
        fileToOpen = file;
      }
    }

    // 2️⃣ لو مش في الكاش، لازم نحمله (Caching Strategy)
    if (fileToOpen == null) {
      // فحص النت
      final isConnected = await connectivityService.connected();
      if (!isConnected) {
        Get.snackbar('Offline', 'File not downloaded yet. Connect to internet to view.',
            backgroundColor: Colors.grey[800]!, colorText: Colors.white);
        return;
      }

      // فيه نت -> نحمل ونخبيه جوه التطبيق
      Get.snackbar('Processing', 'Downloading for offline view...',
          showProgressIndicator: true, backgroundColor: Colors.lightBlue, colorText: Colors.white);

      try {
        final fileBytes = await supa.DownloadedDocUrl(doc.file_Url);
        if (fileBytes.isEmpty) throw Exception("Empty file");

        // 💡 الحفظ في مكان سري وآمن داخل التطبيق
        final appDir = await getApplicationDocumentsDirectory();
        // اسم فريد للملف
        final fileName = '${doc.docId ?? DateTime.now().millisecondsSinceEpoch}_${doc.file_name}';
        final safePath = '${appDir.path}/$fileName';

        fileToOpen = File(safePath);
        await fileToOpen.writeAsBytes(fileBytes);

        // تحديث المودل وتخزين المسار الجديد
        final index = document.indexOf(doc);
        if (index != -1) {
          final updatedDoc = doc.copyWith(local_direct: safePath);
          document[index] = updatedDoc;
          saveDocumentsToLocal(); // ✅ حفظ في الـ GetStorage
        }

      } catch (e) {
        Get.snackbar('Error', 'Failed to download file.', backgroundColor: Colors.red);
        return;
      }
    }

    // 3️⃣ فتح الملف (PDF Viewer)
    if (fileToOpen != null) {
      // إغلاق اللودينج لو كان مفتوح
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

      final result = await OpenFilex.open(fileToOpen.path);
      if (result.type != ResultType.done) {
        Get.snackbar('Error', 'Could not open file: ${result.message}', backgroundColor: Colors.red);
      }
    }
  }

  // ========================================================================
  // 📥 EXPORT LOGIC (Export to Downloads)
  // ========================================================================

  Future<void> downloadDocument(Documents doc) async {
    Get.snackbar('Exporting', 'Saving to Downloads...', backgroundColor: Colors.blue);

    try {
      List<int> bytes;

      // توفير للنت: لو عندنا في الكاش، ننسخه. لو لأ، نحمله.
      if (doc.local_direct != null && File(doc.local_direct!).existsSync()) {
        print("⚡ Getting file from internal cache...");
        bytes = await File(doc.local_direct!).readAsBytes();
      } else {
        print("☁️ Downloading file from server...");
        bytes = await supa.DownloadedDocUrl(doc.file_Url);
      }

      if (bytes.isEmpty) throw Exception('File is empty.');

      final nameWithoutExt = doc.file_name.contains('.')
          ? doc.file_name.split('.').first
          : doc.file_name;

      if (Platform.isAndroid) {
        await FileSaver.instance.saveAs(
            name: nameWithoutExt,
            bytes: Uint8List.fromList(bytes),
            fileExtension: 'pdf',
            mimeType: MimeType.pdf
        );
      } else {
        await FileSaver.instance.saveFile(
            name: nameWithoutExt,
            bytes: Uint8List.fromList(bytes),
            fileExtension: 'pdf',
            mimeType: MimeType.pdf
        );
      }

      Get.snackbar('Success', 'File saved to Downloads!', backgroundColor: Colors.green);

    } catch (e) {
      print('Download Error: $e');
      Get.snackbar('Error', 'Export failed.', backgroundColor: Colors.red);
    }
  }

  // ========================================================================
  // 📤 UPLOAD LOGIC
  // ========================================================================

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['pdf'], type: FileType.custom);

    if (result != null) {
      final PlatformFile file = result.files.single;
      if (file.path != null) {
        selectedFile.value = XFile(file.path!);
        Get.snackbar('Selected', 'File ready.', backgroundColor: Colors.blue.withOpacity(0.5));
      }
    }
  }

  Future<void> uploadDocument() async {
    if (selectedFile.value == null) {
      Get.snackbar('Alert', 'Please select a file first.', backgroundColor: Colors.orange);
      return;
    }

    final fileToUpload = selectedFile.value!;
    isLoading.value = true;
    final isConnected = await connectivityService.connected();

    final newDocument = Documents(
      userId: supa.getCurrentUserId(),
      file_name: fileToUpload.name,
      file_Url: '',
      local_direct: fileToUpload.path, // نحفظ المسار المحلي مؤقتاً
      is_synced: isConnected,
      created_at: DateTime.now(),
    );

    if (isConnected) {
      try {
        final publicUrl = await supa.uploadDocument(fileToUpload);

        if (publicUrl != null) {
          final syncedDoc = newDocument.copyWith(
            file_Url: publicUrl,
            is_synced: true,
          );

          await supa.saveDocumentMetadata(syncedDoc);
          document.insert(0, syncedDoc);

          Get.snackbar('Success', 'Uploaded!', backgroundColor: Colors.green);
        } else {
          throw Exception('Upload failed.');
        }
      } catch (e) {
        document.insert(0, newDocument.copyWith(is_synced: false));
        Get.snackbar('Saved Offline', 'Upload failed, saved locally.', backgroundColor: Colors.orange);
      }
    } else {
      document.insert(0, newDocument.copyWith(is_synced: false));
      Get.snackbar('Offline', 'Saved locally.', backgroundColor: Colors.orange);
    }

    saveDocumentsToLocal();
    selectedFile.value = null;
    isLoading.value = false;
    Get.back();
  }

  // ========================================================================
  // 🔄 SYNC & DELETE & CLEAN
  // ========================================================================

  Future<void> _syncPendingUploads() async {
    final unsyncedDocs = document.where((doc) => doc.is_synced == false).toList();
    if (unsyncedDocs.isEmpty) return;

    for (var doc in unsyncedDocs) {
      if (doc.local_direct == null) continue;
      try {
        final fileToUpload = XFile(doc.local_direct!);
        final publicUrl = await supa.uploadDocument(fileToUpload);
        if (publicUrl != null) {
          final syncedDoc = doc.copyWith(file_Url: publicUrl, is_synced: true);
          await supa.saveDocumentMetadata(syncedDoc);
          final index = document.indexOf(doc);
          if (index != -1) document[index] = syncedDoc;
        }
      } catch (e) {
        print('Sync Error: $e');
      }
    }
    document.refresh();
    saveDocumentsToLocal();
  }

  Future<void> deleteDocument(String? docId, bool isSynced) async {
    if (docId == null && !isSynced) {
      final toDelete = document.where((doc) => doc.is_synced == false && doc.file_Url.isEmpty).toList();
      for (var doc in toDelete) {
        if (doc.local_direct != null && await File(doc.local_direct!).exists()) {
          await File(doc.local_direct!).delete();
        }
      }
      document.removeWhere((doc) => doc.is_synced == false && doc.file_Url.isEmpty);
      saveDocumentsToLocal();
      return;
    }

    if (docId == null) return;

    try {
      isLoading.value = true;
      final docToDelete = document.firstWhereOrNull((doc) => doc.docId == docId);

      if (docToDelete != null) {
        // حذف من السيرفر
        if (docToDelete.is_synced && docToDelete.file_Url.isNotEmpty) {
          await supa.deleteFileFromStorage(docToDelete.file_Url);
          await supa.deleteDocumentMetadata(docId);
        }

        // 🗑️ حذف الملف من الكاش الداخلي (مهم لتوفير المساحة)
        if (docToDelete.local_direct != null) {
          final file = File(docToDelete.local_direct!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        document.removeWhere((doc) => doc.docId == docId);
        saveDocumentsToLocal();

        Get.snackbar('Success', 'Deleted.', backgroundColor: Colors.green);
      }
    } catch (e) {
      Get.snackbar('Error', 'Delete failed.', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  /// دالة إضافية: تنظيف الكاش بالكامل (لو حبيت تضيف زرار في الإعدادات)
  Future<void> clearCachedFiles() async {
    for (var doc in document) {
      if (doc.local_direct != null) {
        final file = File(doc.local_direct!);
        if (await file.exists()) await file.delete();
      }
      final index = document.indexOf(doc);
      document[index] = doc.copyWith(local_direct: null);
    }
    saveDocumentsToLocal();
    Get.snackbar('Cleaned', 'Storage cleared.', backgroundColor: Colors.grey);
  }

  String formatDateTimeManual(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return dateTime.toIso8601String().split('T')[0];
  }
}
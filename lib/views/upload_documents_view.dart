// upload_documents_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/upload_documents_controller.dart';
import 'package:reminder_app/model/document_model.dart';

class UploadDocumentsView extends StatelessWidget {
  const UploadDocumentsView({super.key});

  // ----------------------------------------------------
  // 1. دالة عرض النافذة المنبثقة (Modal Helper Function)
  // ----------------------------------------------------
  void _showUploadModal(BuildContext context, UploadDocumentsController controller) {
    // ... (No change in _showUploadModal)
    // ... (كود دالة _showUploadModal موجود كما هو)

    Widget modalWidget() {
      return AlertDialog(
        title: const Text('Upload Document'),
        // محتوى النافذة المنبثقة
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Select PDF File', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // زر اختيار الملف التفاعلي
            Obx(() => OutlinedButton.icon(
              onPressed: controller.pickPDF,
              icon: const Icon(Icons.upload_file),
              label: Text(
                controller.selectedFile.value?.name ?? 'Choose PDF File',
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )),

            const SizedBox(height: 10),
            const Text(
              'PDF files only, max 10 MB',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

        // أزرار الإجراءات (Cancel و Upload)
        actionsPadding: const EdgeInsets.all(16),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              controller.selectedFile.value = null;
              Get.back();
            },
          ),
          Obx(() => ElevatedButton(
            // تفعيل الزر فقط إذا تم اختيار ملف ولم يكن في حالة تحميل
            onPressed: controller.selectedFile.value != null && !controller.isLoading.value
                ? () {
              controller.uploadDocument();
              // Get.close(1); // تم إزالة هذا السطر لأن Get.back() في الكنترولر سيقوم بالمهمة
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF32CD32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: controller.isLoading.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Upload'),
          )),
        ],
      );
    }
    // عرض النافذة المنبثقة
    Get.dialog(modalWidget(), barrierDismissible: true);
  }

  // ---------------------------------------------------------------------------------
  // 2. الدالة المحلية لإنشاء بطاقة المستند (Inline File Card)
  // ---------------------------------------------------------------------------------
  Widget _buildDocumentCard(Documents doc, UploadDocumentsController controller)  {

    final bool isUnsynced = !doc.is_synced; // 💡 حالة عدم المزامنة

    const String size = 'pdf';
    const String label = 'docs';
    final String dateDisplay = controller.formatDateTimeManual(doc.created_at);

    // 💡 تغيير لون البطاقة للدلالة على عدم المزامنة
    final Color cardColor = isUnsynced ? Colors.orange.shade50 : Colors.white;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor, // 💡 تطبيق لون البطاقة
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // أيقونة الملف
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description, color: Color(0xFF42A5F5), size: 30),
            ),
            const SizedBox(width: 15),

            // المحتوى الرئيسي (الاسم والبيانات الوصفية)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row( // 💡 إضافة Row لاحتواء مؤشر حالة الملف
                    children: [
                      Expanded(
                        child: Text(
                          doc.file_name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // 💡 مؤشر عدم المزامنة
                      if (isUnsynced)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.sync_problem, color: Colors.orange, size: 18),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // ✅ تم لفه بـ Expanded لحل Overflow لو كان label طويلاً
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              label,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(size, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(dateDisplay, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),

            // أزرار الإجراءات الجانبية
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // 💡 تعديل viewDocument لتمرير local_direct
                IconButton(
                    icon: const Icon(Icons.remove_red_eye_outlined),
                    color: Colors.grey.shade600,
                    // بنبعت الـ doc كله عشان الدالة تحدث المسار جواه لو حملته
                    onPressed: () => controller.viewDocument(doc)
                ),
                // زر التحميل يكون مُعطل لو الملف لسة أوفلاين (لأنه محتاج رابط السوبا)
                IconButton(
                    icon: const Icon(Icons.download),
                    color: isUnsynced ? Colors.grey.shade400 : Colors.grey.shade600,
                    onPressed: isUnsynced
                        ? null // تعطيل إذا لم تتم المزامنة
                        : () async => await controller.downloadDocument(doc)
                ),
                // 💡 تعديل deleteDocument لتمرير is_synced
                IconButton(
                    icon: const Icon(Icons.delete_forever),
                    color: Colors.red,
                    onPressed: () => controller.deleteDocument(doc.docId, doc.is_synced)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // ... (Rest of build function remains the same)
    // ... (كود دالة build موجود كما هو)
    final controller = Get.find<UploadDocumentsController>();
    const Color unifiedBlue = Color(0xFF80D8FF);

    return Scaffold(
      appBar: null,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 1. الجزء العلوي الموحد (Header Area) - اللون الأزرق الموحد
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 20, left: 16, right: 16),
            decoration: const BoxDecoration(
              color: unifiedBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(onTap: () => Get.back(), child: const Icon(Icons.arrow_back_ios, color: Colors.white)),
                const Text('Documents', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(width: 24),
              ],
            ),
          ),

          // 2. العنوان وزرار Upload
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // العنوان التفاعلي لعدد المستندات
                Obx(() => Text(
                  'Your Documents (${controller.document.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )),

                // زر الـ Upload
                GestureDetector(
                  // 💡 عند الضغط، يتم استدعاء دالة عرض النافذة المنبثقة المحلية
                  onTap: () => _showUploadModal(context, controller),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF80D8FF)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.upload, color: Colors.white, size: 24), SizedBox(width: 8), Text('Upload', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. القائمة التفاعلية (ListView)
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.document.isEmpty) {
                return const Center(child: SpinKitPumpingHeart(color: Colors.lightBlue,));
              }
              if (controller.document.isEmpty) {
                return const Center(child: Text('Upload your Documents,Records and Descriptions here'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.fetechDOCS();
                },
                color: Colors.blueAccent,
                child:controller.document.isEmpty?
                ListView( // لازم ListView عشان السحب يشتغل حتى لو فاضية
                  children: const [
                    SizedBox(height: 200),
                    Center(child: Text('No documents found. Pull to refresh.')),
                  ],
                )
                :
                ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: controller.document.length,
                  itemBuilder: (context, index) {
                    final doc = controller.document[index];
                    // 💡 استدعاء الدالة المحلية لإنشاء البطاقة
                    return  _buildDocumentCard(doc, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
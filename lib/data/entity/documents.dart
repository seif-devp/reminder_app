
import 'package:floor/floor.dart';
import 'package:reminder_app/data/entity/users.dart';

@Entity(
  tableName: 'documents',
  foreignKeys: [
    ForeignKey(
      childColumns: ['userId'],
      parentColumns: ['userId'],
      entity: User,
      onDelete: ForeignKeyAction.cascade,
      onUpdate: ForeignKeyAction.cascade,
    ),
  ],
)
class Document {
  @PrimaryKey(autoGenerate: true)
  final int? docId;
  final String userId;
  final String fileUrl;
  final String fileName;
  final String? syncStatus; // 'synced' or 'not_synced'

  Document({
    this.docId,
    required this.userId,
    required this.fileUrl,
    required this.fileName,
    this.syncStatus,
  });
}
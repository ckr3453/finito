import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/enums/enums.dart';

class TaskFirestoreDto {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? categoryId;
  final List<String> tagIds;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? reminderTime;
  final DateTime? deletedAt;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskFirestoreDto({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.categoryId,
    required this.tagIds,
    this.dueDate,
    this.completedAt,
    this.reminderTime,
    this.deletedAt,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskFirestoreDto.fromFirestore(Map<String, dynamic> data) {
    return TaskFirestoreDto(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      status: data['status'] as String,
      priority: data['priority'] as String,
      categoryId: data['categoryId'] as String?,
      tagIds:
          (data['tagIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      reminderTime: (data['reminderTime'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      sortOrder: data['sortOrder'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory TaskFirestoreDto.fromEntity(TaskEntity entity) {
    return TaskFirestoreDto(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      status: entity.status.name,
      priority: entity.priority.name,
      categoryId: entity.categoryId,
      tagIds: entity.tagIds,
      dueDate: entity.dueDate,
      completedAt: entity.completedAt,
      reminderTime: entity.reminderTime,
      deletedAt: entity.deletedAt,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'categoryId': categoryId,
      'tagIds': tagIds,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'reminderTime': reminderTime != null
          ? Timestamp.fromDate(reminderTime!)
          : null,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'reminderEmailSent': reminderTime == null ? null : false,
    };
  }

  TaskEntity toEntity({required bool isSynced}) {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      status: TaskStatus.values.byName(status),
      priority: Priority.values.byName(priority),
      categoryId: categoryId,
      tagIds: tagIds,
      dueDate: dueDate,
      completedAt: completedAt,
      reminderTime: reminderTime,
      deletedAt: deletedAt,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }
}

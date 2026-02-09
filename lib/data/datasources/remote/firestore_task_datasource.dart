import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/data/datasources/remote/firestore_paths.dart';
import 'package:todo_app/data/models/task_firestore_dto.dart';

abstract class FirestoreTaskDataSource {
  Stream<List<TaskFirestoreDto>> watchTasks(String userId);
  Future<void> setTask(String userId, TaskFirestoreDto dto);
  Future<void> batchSetTasks(String userId, List<TaskFirestoreDto> dtos);
  Future<List<TaskFirestoreDto>> fetchAllTasks(String userId);
}

class FirestoreTaskDataSourceImpl implements FirestoreTaskDataSource {
  final FirebaseFirestore _firestore;

  FirestoreTaskDataSourceImpl(this._firestore);

  @override
  Stream<List<TaskFirestoreDto>> watchTasks(String userId) {
    return _firestore
        .collection(FirestorePaths.tasksCol(userId))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskFirestoreDto.fromFirestore(doc.data()))
            .toList());
  }

  @override
  Future<void> setTask(String userId, TaskFirestoreDto dto) {
    return _firestore
        .doc(FirestorePaths.taskDoc(userId, dto.id))
        .set(dto.toFirestore());
  }

  @override
  Future<void> batchSetTasks(String userId, List<TaskFirestoreDto> dtos) {
    final batch = _firestore.batch();
    for (final dto in dtos) {
      final docRef = _firestore.doc(FirestorePaths.taskDoc(userId, dto.id));
      batch.set(docRef, dto.toFirestore());
    }
    return batch.commit();
  }

  @override
  Future<List<TaskFirestoreDto>> fetchAllTasks(String userId) async {
    final snapshot =
        await _firestore.collection(FirestorePaths.tasksCol(userId)).get();
    return snapshot.docs
        .map((doc) => TaskFirestoreDto.fromFirestore(doc.data()))
        .toList();
  }
}

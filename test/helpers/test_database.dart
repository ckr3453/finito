import 'package:drift/native.dart';
import 'package:todo_app/data/database/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

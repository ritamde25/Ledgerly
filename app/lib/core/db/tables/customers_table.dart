import 'package:drift/drift.dart';

class Customers extends Table {
  TextColumn get id => text()(); // Changed from autoIncrement to TEXT for UUID support
  TextColumn get name => text()();
  TextColumn get phone => text()();
  RealColumn get totalDue => real().withDefault(Constant(0))();

  TextColumn get userId => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

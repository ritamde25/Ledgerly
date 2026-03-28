import 'package:drift/drift.dart';

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  RealColumn get totalDue => real().withDefault(Constant(0))();

  TextColumn get userId => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(Constant(false))();
}

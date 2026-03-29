import 'package:drift/drift.dart';

class BaseInventoryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get defaultPrice => real()();
  TextColumn get yoloLabel => text()();
  RealColumn get baseQuantity => real().withDefault(const Constant(1.0))();
  TextColumn get quantityMetric => text().withDefault(const Constant('pcs'))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class InventoryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()(); // Nullable because it might be inherited from base
  RealColumn get price => real().nullable()(); // Nullable because it might be inherited from base

  TextColumn get yoloLabel => text().nullable()(); // Nullable if it's a shop-specific item without label
  TextColumn get userId => text()();
  
  IntColumn get baseItemId => integer().nullable().references(BaseInventoryItems, #id)();
  BoolColumn get isOverride => boolean().withDefault(const Constant(false))();
  RealColumn get baseQuantity => real().nullable()();
  TextColumn get quantityMetric => text().nullable()();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

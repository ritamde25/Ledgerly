import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/customers_table.dart';
import 'tables/inventory_table.dart';
import 'tables/transactions_table.dart';
import 'daos/customers_dao.dart';
import 'daos/inventory_dao.dart';
import 'daos/transactions_dao.dart';
import 'models/item.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [Customers, BaseInventoryItems, InventoryItems, Transactions],
  daos: [CustomersDao, InventoryDao, TransactionsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // Bumped version for updatedAt

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(baseInventoryItems);
          await m.addColumn(inventoryItems, inventoryItems.baseItemId);
          await m.addColumn(inventoryItems, inventoryItems.isOverride);
          await m.addColumn(inventoryItems, inventoryItems.baseQuantity);
          await m.addColumn(inventoryItems, inventoryItems.quantityMetric);
        }
        if (from < 3) {
          await m.addColumn(baseInventoryItems, baseInventoryItems.updatedAt);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

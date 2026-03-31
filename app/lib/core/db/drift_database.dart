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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    // print("The size of the db is - ${(await file.length()) / (1024 * 1024)} MB");
    return NativeDatabase.createInBackground(file);
  });
}

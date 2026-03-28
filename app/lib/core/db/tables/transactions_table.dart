import 'dart:convert';
import 'package:drift/drift.dart';
import 'customers_table.dart';
import '../models/item.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  TextColumn get itemsJson => text().map(const ItemsConverter())(); 
  RealColumn get totalAmount => real()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  TextColumn get userId => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(Constant(false))();
}

class ItemsConverter extends TypeConverter<List<Item>, String> {
  const ItemsConverter();

  @override
  List<Item> fromSql(String fromDb) {
    final List<dynamic> decoded = json.decode(fromDb);
    return decoded.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  String toSql(List<Item> value) {
    return json.encode(value.map((e) => e.toJson()).toList());
  }
}

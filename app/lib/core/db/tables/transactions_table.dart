import 'dart:convert';
import 'package:drift/drift.dart';
import '../models/item.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  TextColumn get itemsJson => text().map(const ItemsConverter())(); 
  RealColumn get totalAmount => real()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)(); // Track when created locally

  TextColumn get userId => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
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

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/db/drift_database.dart';
import '../core/db/models/item.dart';
import 'package:drift/drift.dart' as drift;

class SyncService {
  final AppDatabase db;
  final SupabaseClient supabase;

  SyncService({required this.db, required this.supabase});

  Future<void> syncAll() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      await _syncBaseInventory();
      debugPrint('Sync skipped: No user logged in');
      return;
    }

    debugPrint('Starting Sync for user: ${user.id}');
    
    try {
      await _syncBaseInventory();
      await _syncCustomers(user.id);
      await _syncInventory(user.id);
      await _syncTransactions(user.id);
      debugPrint('✅ Sync Completed Successfully');
    } catch (e) {
      debugPrint('❌ Sync Failed: $e');
    }
  }

  Future<void> _syncBaseInventory() async {
    try {
      // Get the latest updated_at from local DB
      final lastUpdateQuery = db.select(db.baseInventoryItems)
        ..orderBy([(t) => drift.OrderingTerm(expression: t.updatedAt, mode: drift.OrderingMode.desc)])
        ..limit(1);
      final lastUpdateItem = await lastUpdateQuery.getSingleOrNull();
      final lastUpdate = lastUpdateItem?.updatedAt;

      var query = supabase.from('base_inventory_items').select();
      
      // If we have a local timestamp, only fetch items updated after that
      if (lastUpdate != null) {
        query = query.gt('updated_at', lastUpdate.toIso8601String());
      }

      final response = await query;
      final List<dynamic> data = response as List<dynamic>;

      if (data.isEmpty) {
        debugPrint('Base inventory is up to date');
        return;
      }

      for (final item in data) {
        await db.into(db.baseInventoryItems).insert(
          BaseInventoryItemsCompanion(
            id: drift.Value(item['id']),
            name: drift.Value(item['name']),
            defaultPrice: drift.Value(item['default_price']?.toDouble() ?? 0.0),
            yoloLabel: drift.Value(item['yolo_label']),
            baseQuantity: drift.Value(item['base_quantity']?.toDouble() ?? 1.0),
            quantityMetric: drift.Value(item['quantity_metric'] ?? 'pcs'),
            updatedAt: drift.Value(DateTime.parse(item['updated_at'])),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
      }
      debugPrint('Synced ${data.length} new/updated base inventory items');
    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      debugPrint('Error syncing base inventory: $e');
    }
  }

  Future<void> _syncCustomers(String userId) async {
    final unsynced = await (db.select(db.customers)..where((t) => t.isSynced.equals(false))).get();
    debugPrint('Found ${unsynced.length} unsynced customers');

    for (final customer in unsynced) {
      debugPrint('Syncing customer: ${customer.name}, Due: ${customer.totalDue}');
      
      await supabase.from('customers').upsert({
        'id': customer.id,
        'user_id': userId,
        'name': customer.name,
        'phone': customer.phone,
        'total_due': customer.totalDue,
      });

      await (db.update(db.customers)..where((t) => t.id.equals(customer.id)))
          .write(const CustomersCompanion(isSynced: drift.Value(true)));
    }
  }

  Future<void> _syncInventory(String userId) async {
    final unsynced = await (db.select(db.inventoryItems)..where((t) => t.isSynced.equals(false))).get();

    for (final item in unsynced) {
      await supabase.from('inventory_items').upsert({
        'id': item.id,
        'user_id': userId,
        'name': item.name,
        'price': item.price,
        'yolo_label': item.yoloLabel,
        'base_item_id': item.baseItemId,
        'is_override': item.isOverride,
        'base_quantity': item.baseQuantity,
        'quantity_metric': item.quantityMetric,
      });

      await (db.update(db.inventoryItems)..where((t) => t.id.equals(item.id)))
          .write(const InventoryItemsCompanion(isSynced: drift.Value(true)));
    }
  }

  Future<void> _syncTransactions(String userId) async {
    final unsynced = await (db.select(db.transactions)..where((t) => t.isSynced.equals(false))).get();

    for (final tx in unsynced) {
      final jsonItems = json.encode(tx.itemsJson.map((e) => e.toJson()).toList());

      await supabase.from('transactions').upsert({
        'id': tx.id,
        'user_id': userId,
        'customer_id': tx.customerId,
        'items_json': jsonItems,
        'total_amount': tx.totalAmount,
        'timestamp': tx.timestamp.toIso8601String(),
      });

      await (db.update(db.transactions)..where((t) => t.id.equals(tx.id)))
          .write(const TransactionsCompanion(isSynced: drift.Value(true)));
    }
  }
}

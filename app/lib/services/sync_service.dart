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
    } catch (e, stackTrace) {
      debugPrint('❌ Sync Failed: $e');
      debugPrintStack(stackTrace: stackTrace);
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
    try {
      // 1. PUSH unsynced changes FIRST (before pulling)
      final unsynced = await (db.select(db.customers)..where((t) => t.isSynced.equals(false))).get();
      debugPrint('Found ${unsynced.length} unsynced customers to push');

      for (final customer in unsynced) {
        debugPrint('Pushing customer: ${customer.name}, Due: ${customer.totalDue}');
        
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

      // 2. PULL from Supabase AFTER pushing (to get remote updates)
      final response = await supabase.from('customers').select().eq('user_id', userId);
      final List<dynamic> data = response as List<dynamic>;
      
      for (final item in data) {
        // Only insert if not locally unsynced (to not overwrite pending changes)
        final existingCustomer = await (db.select(db.customers)
          ..where((t) => t.id.equals(item['id']))
          ..limit(1)).getSingleOrNull();
        
        if (existingCustomer != null && !existingCustomer.isSynced) {
          debugPrint('Skipping pull for unsynced customer: ${item['name']}');
          continue;
        }

        await db.into(db.customers).insert(
          CustomersCompanion(
            id: drift.Value(item['id']),
            name: drift.Value(item['name']),
            phone: drift.Value(item['phone'] ?? ''),
            totalDue: drift.Value(item['total_due']?.toDouble() ?? 0.0),
            userId: drift.Value(item['user_id']),
            isSynced: const drift.Value(true),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
      }
      if (data.isNotEmpty) {
        debugPrint('Pulled ${data.length} customers from Supabase');
      }
    } catch (e) {
      debugPrint('Error syncing customers: $e');
    }
  }

  Future<void> _syncInventory(String userId) async {
    try {
      // 1. Pull from Supabase
      final response = await supabase.from('inventory_items').select().eq('user_id', userId);
      final List<dynamic> data = response as List<dynamic>;
      
      for (final item in data) {
        await db.into(db.inventoryItems).insert(
          InventoryItemsCompanion(
            id: drift.Value(item['id']),
            name: drift.Value(item['name']),
            price: drift.Value(item['price']?.toDouble()),
            yoloLabel: drift.Value(item['yolo_label']),
            userId: drift.Value(item['user_id']),
            baseItemId: drift.Value(item['base_item_id']),
            isOverride: drift.Value(item['is_override'] ?? false),
            baseQuantity: drift.Value(item['base_quantity']?.toDouble()),
            quantityMetric: drift.Value(item['quantity_metric']),
            isSynced: const drift.Value(true),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
      }
      if (data.isNotEmpty) {
        debugPrint('Pulled ${data.length} inventory items from Supabase');
      }
    } catch (e) {
      debugPrint('Error pulling inventory: $e');
    }

    // 2. Push unsynced
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
    try {
      // 1. PUSH unsynced transactions FIRST
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
          'created_at': tx.createdAt.toIso8601String(),
        });

        await (db.update(db.transactions)..where((t) => t.id.equals(tx.id)))
            .write(const TransactionsCompanion(isSynced: drift.Value(true)));
      }
      if (unsynced.isNotEmpty) {
        debugPrint('✅ Pushed ${unsynced.length} transactions to Supabase');
      }
    } catch (e) {
      debugPrint('❌ Error pushing transactions: $e');
    }

    // 2. PULL new transactions from Supabase (incremental)
    try {
      // Get the latest created_at timestamp from local transactions
      final latestLocalQuery = db.select(db.transactions)
        ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)])
        ..limit(1);
      final latestLocal = await latestLocalQuery.getSingleOrNull();
      
      var query = supabase.from('transactions').select().eq('user_id', userId);
      
      // Only fetch transactions created after the latest local one
      if (latestLocal != null) {
        query = query.gt('created_at', latestLocal.createdAt.toIso8601String());
        debugPrint('Fetching transactions created after: ${latestLocal.createdAt}');
      }

      final response = await query;
      final List<dynamic> data = response as List<dynamic>;
      
      for (final item in data) {
        final itemsData = item['items_json'];
        List<Item> items = [];
        if (itemsData is String) {
          final List<dynamic> decoded = json.decode(itemsData);
          items = decoded.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
        } else if (itemsData is List) {
          items = itemsData.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
        }

        // Use insertOrIgnore to not overwrite any local changes
        await db.into(db.transactions).insert(
          TransactionsCompanion(
            id: drift.Value(item['id']),
            customerId: drift.Value(item['customer_id']),
            itemsJson: drift.Value(items),
            totalAmount: drift.Value(item['total_amount']?.toDouble() ?? 0.0),
            timestamp: drift.Value(DateTime.parse(item['timestamp'])),
            createdAt: drift.Value(DateTime.parse(item['created_at'])),
            userId: drift.Value(item['user_id']),
            isSynced: const drift.Value(true),
          ),
          mode: drift.InsertMode.insertOrIgnore, // Don't overwrite existing local transactions
        );
      }
      if (data.isNotEmpty) {
        debugPrint('✅ Pulled ${data.length} new transactions from Supabase');
      }
    } catch (e) {
      debugPrint('❌ Error pulling transactions: $e');
    }
  }
}

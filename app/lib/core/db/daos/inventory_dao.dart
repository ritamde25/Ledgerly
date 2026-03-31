import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/inventory_table.dart';

part 'inventory_dao.g.dart';

class UnifiedInventoryItem {
  final String itemId;
  final String name;
  final double price;
  final String? yoloLabel;
  final double baseQuantity;
  final String quantityMetric;
  final bool isOverride;
  final String source;

  UnifiedInventoryItem({
    required this.itemId,
    required this.name,
    required this.price,
    this.yoloLabel,
    required this.baseQuantity,
    required this.quantityMetric,
    required this.isOverride,
    required this.source,
  });
}

@DriftAccessor(tables: [InventoryItems, BaseInventoryItems])
class InventoryDao extends DatabaseAccessor<AppDatabase> with _$InventoryDaoMixin {
  InventoryDao(AppDatabase db) : super(db);

  Stream<List<InventoryItem>> watchAllItems() => select(inventoryItems).watch();
  Future<List<InventoryItem>> getAllItems() => select(inventoryItems).get();
  
  Future<List<BaseInventoryItem>> getAllBaseItems() => select(baseInventoryItems).get();
  Future<int> insertBaseItem(BaseInventoryItemsCompanion item) => into(baseInventoryItems).insert(item);

  Stream<List<UnifiedInventoryItem>> watchUnifiedInventory(
    String userId, {
    String? query,
    int? limit,
    int? offset,
  }) {
    final searchPattern = query != null && query.isNotEmpty ? '%$query%' : null;
    
    final sql = '''
      SELECT * FROM (
        SELECT 
            COALESCE(si.id, bi.id) as item_id,
            COALESCE(si.name, bi.name) as name,
            COALESCE(si.price, bi.default_price) as price,
            bi.yolo_label,
            COALESCE(si.base_quantity, bi.base_quantity) as base_quantity,
            COALESCE(si.quantity_metric, bi.quantity_metric) as quantity_metric,
            CASE WHEN si.id IS NOT NULL AND si.is_override = 1 THEN 1 ELSE 0 END as is_override,
            CASE WHEN si.id IS NULL THEN 'base' ELSE 'shop' END as source
        FROM base_inventory_items bi
        LEFT JOIN inventory_items si ON si.base_item_id = bi.id AND si.user_id = ?
        UNION
        SELECT 
            id as item_id,
            name,
            price,
            NULL as yolo_label,
            base_quantity,
            quantity_metric,
            0 as is_override,
            'shop' as source
        FROM inventory_items
        WHERE user_id = ? AND base_item_id IS NULL
      ) AS unified
      ${searchPattern != null ? 'WHERE name LIKE ? OR yolo_label LIKE ?' : ''}
      ORDER BY name ASC
      ${limit != null ? 'LIMIT ?' : ''}
      ${offset != null ? 'OFFSET ?' : ''}
    ''';

    final variables = [
      Variable.withString(userId),
      Variable.withString(userId),
      if (searchPattern != null) ...[
        Variable.withString(searchPattern),
        Variable.withString(searchPattern),
      ],
      if (limit != null) Variable.withInt(limit),
      if (offset != null) Variable.withInt(offset),
    ];

    return customSelect(
      sql,
      variables: variables,
      readsFrom: {baseInventoryItems, inventoryItems},
    ).watch().map((rows) {
      return rows.map((row) {
        return UnifiedInventoryItem(
          itemId: row.read<int>('item_id').toString(),
          name: row.read<String>('name'),
          price: row.read<double>('price'),
          yoloLabel: row.readNullable<String>('yolo_label'),
          baseQuantity: row.read<double>('base_quantity'),
          quantityMetric: row.read<String>('quantity_metric'),
          isOverride: row.read<int>('is_override') == 1,
          source: row.read<String>('source'),
        );
      }).toList();
    });
  }

  Future<List<UnifiedInventoryItem>> getUnifiedInventory(
    String userId, {
    String? query,
    int? limit,
    int? offset,
  }) async {
    final searchPattern = query != null && query.isNotEmpty ? '%$query%' : null;

    final sql = '''
      SELECT * FROM (
        SELECT 
            COALESCE(si.id, bi.id) as item_id,
            COALESCE(si.name, bi.name) as name,
            COALESCE(si.price, bi.default_price) as price,
            bi.yolo_label,
            COALESCE(si.base_quantity, bi.base_quantity) as base_quantity,
            COALESCE(si.quantity_metric, bi.quantity_metric) as quantity_metric,
            CASE WHEN si.id IS NOT NULL AND si.is_override = 1 THEN 1 ELSE 0 END as is_override,
            CASE WHEN si.id IS NULL THEN 'base' ELSE 'shop' END as source
        FROM base_inventory_items bi
        LEFT JOIN inventory_items si ON si.base_item_id = bi.id AND si.user_id = ?
        UNION
        SELECT 
            id as item_id,
            name,
            price,
            NULL as yolo_label,
            base_quantity,
            quantity_metric,
            0 as is_override,
            'shop' as source
        FROM inventory_items
        WHERE user_id = ? AND base_item_id IS NULL
      ) AS unified
      ${searchPattern != null ? 'WHERE name LIKE ? OR yolo_label LIKE ?' : ''}
      ORDER BY name ASC
      ${limit != null ? 'LIMIT ?' : ''}
      ${offset != null ? 'OFFSET ?' : ''}
    ''';

    final variables = [
      Variable.withString(userId),
      Variable.withString(userId),
      if (searchPattern != null) ...[
        Variable.withString(searchPattern),
        Variable.withString(searchPattern),
      ],
      if (limit != null) Variable.withInt(limit),
      if (offset != null) Variable.withInt(offset),
    ];

    final rows = await customSelect(
      sql,
      variables: variables,
      readsFrom: {baseInventoryItems, inventoryItems},
    ).get();

    return rows.map((row) {
      return UnifiedInventoryItem(
        itemId: row.read<int>('item_id').toString(),
        name: row.read<String>('name'),
        price: row.read<double>('price'),
        yoloLabel: row.readNullable<String>('yolo_label'),
        baseQuantity: row.read<double>('base_quantity'),
        quantityMetric: row.read<String>('quantity_metric'),
        isOverride: row.read<int>('is_override') == 1,
        source: row.read<String>('source'),
      );
    }).toList();
  }

  Future<int> insertItem(InventoryItemsCompanion item) => into(inventoryItems).insert(item);
  Future updateItem(InventoryItem item) => update(inventoryItems).replace(item);
  Future deleteItem(InventoryItem item) => delete(inventoryItems).delete(item);
}

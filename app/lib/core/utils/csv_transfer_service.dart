import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../db/drift_database.dart';
import '../db/models/item.dart';

class CsvImportResult {
  final int inserted;
  final int updated;
  final int skipped;
  final int failed;

  const CsvImportResult({
    required this.inserted,
    required this.updated,
    required this.skipped,
    required this.failed,
  });

  String toSummary(String label) {
    return '$label import complete. Added: $inserted, Updated: $updated, Skipped: $skipped, Failed: $failed';
  }
}

class CsvTransferService {
  final AppDatabase db;
  final String userId;

  CsvTransferService({required this.db, required this.userId});

  Future<String> exportCustomersToCsv() async {
    final customerRows = await (db.select(db.customers)
          ..where((t) => t.userId.isNull() | t.userId.equals(userId)))
        .get();

    final rows = <List<dynamic>>[
      ['id', 'name', 'phone', 'totalDue'],
      ...customerRows.map((c) => [
            c.id,
            c.name,
            c.phone,
            c.totalDue,
          ]),
    ];

    return _shareCsvFile(
      filePrefix: 'customers',
      csvContent: const CsvEncoder().convert(rows),
    );
  }

  Future<CsvImportResult> importCustomersFromCsv() async {
    final csvData = await _pickCsvContent();
    final parsed = const CsvDecoder(dynamicTyping: false).convert(csvData);
    if (parsed.isEmpty) {
      return const CsvImportResult(inserted: 0, updated: 0, skipped: 0, failed: 0);
    }

    final headers = parsed.first.map((h) => h.toString().trim()).toList();
    int inserted = 0;
    int updated = 0;
    int skipped = 0;
    int failed = 0;

    for (final row in parsed.skip(1)) {
      try {
        final rowMap = _rowToMap(headers, row);
        final name = (rowMap['name'] ?? '').trim();
        if (name.isEmpty) {
          skipped++;
          continue;
        }

        final id = (rowMap['id'] ?? '').trim().isNotEmpty ? rowMap['id']!.trim() : const Uuid().v4();
        final phone = (rowMap['phone'] ?? '').trim();
        final totalDue = _tryParseDouble(rowMap['totalDue']) ?? 0;

        final existing = await (db.select(db.customers)..where((t) => t.id.equals(id))).getSingleOrNull();

        if (existing == null) {
          await db.into(db.customers).insert(
                CustomersCompanion.insert(
                  id: id,
                  name: name,
                  phone: phone,
                  totalDue: drift.Value(totalDue),
                  userId: drift.Value(userId),
                  isSynced: const drift.Value(false),
                ),
              );
          inserted++;
        } else {
          await db.update(db.customers).replace(
                existing.copyWith(
                  name: name,
                  phone: phone,
                  totalDue: totalDue,
                  userId: drift.Value(userId),
                  isSynced: false,
                ),
              );
          updated++;
        }
      } catch (_) {
        failed++;
      }
    }

    return CsvImportResult(inserted: inserted, updated: updated, skipped: skipped, failed: failed);
  }

  Future<String> exportTransactionsToCsv() async {
    final txRows = await (db.select(db.transactions)
          ..where((t) => t.userId.isNull() | t.userId.equals(userId))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.timestamp)]))
        .get();

    final customerRows = await (db.select(db.customers)
          ..where((t) => t.userId.isNull() | t.userId.equals(userId)))
        .get();
    final customerById = {for (final c in customerRows) c.id: c};

    final rows = <List<dynamic>>[
      [
        'id',
        'customerId',
        'customerName',
        'customerPhone',
        'totalAmount',
        'timestamp',
        'createdAt',
        'itemsJson',
      ],
      ...txRows.map((t) {
        final customer = customerById[t.customerId];
        return [
          t.id,
          t.customerId,
          customer?.name ?? '',
          customer?.phone ?? '',
          t.totalAmount,
          t.timestamp.toIso8601String(),
          t.createdAt.toIso8601String(),
          jsonEncode(t.itemsJson.map((e) => e.toJson()).toList()),
        ];
      }),
    ];

    return _shareCsvFile(
      filePrefix: 'transactions',
      csvContent: const CsvEncoder().convert(rows),
    );
  }

  Future<CsvImportResult> importTransactionsFromCsv() async {
    final csvData = await _pickCsvContent();
    final parsed = const CsvDecoder(dynamicTyping: false).convert(csvData);
    if (parsed.isEmpty) {
      return const CsvImportResult(inserted: 0, updated: 0, skipped: 0, failed: 0);
    }

    final headers = parsed.first.map((h) => h.toString().trim()).toList();
    int inserted = 0;
    int updated = 0;
    int skipped = 0;
    int failed = 0;

    for (final row in parsed.skip(1)) {
      try {
        final rowMap = _rowToMap(headers, row);
        final txId = (rowMap['id'] ?? '').trim().isNotEmpty ? rowMap['id']!.trim() : const Uuid().v4();

        final customerIdRaw = (rowMap['customerId'] ?? '').trim();
        final customerName = (rowMap['customerName'] ?? '').trim();
        final customerPhone = (rowMap['customerPhone'] ?? '').trim();
        final resolvedCustomerId = customerIdRaw.isNotEmpty ? customerIdRaw : const Uuid().v4();

        if (customerName.isEmpty && customerIdRaw.isEmpty) {
          skipped++;
          continue;
        }

        final amount = _tryParseDouble(rowMap['totalAmount']) ?? 0;
        final timestamp = _tryParseDateTime(rowMap['timestamp']) ?? DateTime.now();
        final createdAt = _tryParseDateTime(rowMap['createdAt']) ?? timestamp;
        final items = _parseItemsJson(rowMap['itemsJson']);

        final existingCustomer = await (db.select(db.customers)
              ..where((t) => t.id.equals(resolvedCustomerId)))
            .getSingleOrNull();

        if (existingCustomer == null) {
          await db.into(db.customers).insert(
                CustomersCompanion.insert(
                  id: resolvedCustomerId,
                  name: customerName.isNotEmpty ? customerName : 'Imported Customer',
                  phone: customerPhone,
                  userId: drift.Value(userId),
                  isSynced: const drift.Value(false),
                ),
              );
        } else if (customerName.isNotEmpty || customerPhone.isNotEmpty) {
          await db.update(db.customers).replace(
                existingCustomer.copyWith(
                  name: customerName.isNotEmpty ? customerName : existingCustomer.name,
                  phone: customerPhone.isNotEmpty ? customerPhone : existingCustomer.phone,
                  userId: drift.Value(userId),
                  isSynced: false,
                ),
              );
        }

        final existingTx = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingleOrNull();

        if (existingTx == null) {
          await db.into(db.transactions).insert(
                TransactionsCompanion.insert(
                  id: txId,
                  customerId: resolvedCustomerId,
                  itemsJson: items,
                  totalAmount: amount,
                  timestamp: drift.Value(timestamp),
                  createdAt: drift.Value(createdAt),
                  userId: drift.Value(userId),
                  isSynced: const drift.Value(false),
                ),
              );
          inserted++;
        } else {
          await db.update(db.transactions).replace(
                existingTx.copyWith(
                  customerId: resolvedCustomerId,
                  itemsJson: items,
                  totalAmount: amount,
                  timestamp: timestamp,
                  createdAt: createdAt,
                  userId: drift.Value(userId),
                  isSynced: false,
                ),
              );
          updated++;
        }
      } catch (_) {
        failed++;
      }
    }

    return CsvImportResult(inserted: inserted, updated: updated, skipped: skipped, failed: failed);
  }

  Future<String> exportInventoryToCsv() async {
    final unifiedRows = await _getUnifiedInventoryRows();
    final rows = <List<dynamic>>[
      [
        'source',
        'itemId',
        'baseItemId',
        'name',
        'price',
        'baseQuantity',
        'quantityMetric',
        'yoloLabel',
        'isOverride',
      ],
      ...unifiedRows.map((r) => [
            r['source'],
            r['itemId'],
            r['baseItemId'],
            r['name'],
            r['price'],
            r['baseQuantity'],
            r['quantityMetric'],
            r['yoloLabel'],
            r['isOverride'],
          ]),
    ];

    return _shareCsvFile(
      filePrefix: 'inventory',
      csvContent: const CsvEncoder().convert(rows),
    );
  }

  Future<CsvImportResult> importInventoryFromCsv() async {
    final csvData = await _pickCsvContent();
    final parsed = const CsvDecoder(dynamicTyping: false).convert(csvData);
    if (parsed.isEmpty) {
      return const CsvImportResult(inserted: 0, updated: 0, skipped: 0, failed: 0);
    }

    final headers = parsed.first.map((h) => h.toString().trim()).toList();
    int inserted = 0;
    int updated = 0;
    int skipped = 0;
    int failed = 0;

    final baseRows = await db.select(db.baseInventoryItems).get();
    final baseById = {for (final b in baseRows) b.id: b};
    final baseByName = {for (final b in baseRows) b.name.toLowerCase().trim(): b};

    final userRows = await (db.select(db.inventoryItems)..where((t) => t.userId.equals(userId))).get();
    final userById = {for (final r in userRows) r.id: r};
    final userByBaseId = {
      for (final r in userRows)
        if (r.baseItemId != null) r.baseItemId!: r,
    };

    for (final row in parsed.skip(1)) {
      try {
        final rowMap = _rowToMap(headers, row);
        final source = (rowMap['source'] ?? '').trim().toLowerCase();
        final rowName = (rowMap['name'] ?? '').trim();
        final rowPrice = _tryParseDouble(rowMap['price']) ?? 0;
        final rowQty = _tryParseDouble(rowMap['baseQuantity']) ?? 1;
        final rowMetric = (rowMap['quantityMetric'] ?? '').trim().isEmpty ? 'pcs' : rowMap['quantityMetric']!.trim();

        if (rowName.isEmpty) {
          skipped++;
          continue;
        }

        final baseItemId = _tryParseInt(rowMap['baseItemId']) ??
            (source == 'base' ? _tryParseInt(rowMap['itemId']) : null) ??
            baseByName[rowName.toLowerCase()]?.id;

        if (baseItemId != null && baseById.containsKey(baseItemId)) {
          final base = baseById[baseItemId]!;
          final isSameAsBase =
              rowName == base.name && rowPrice == base.defaultPrice && rowQty == base.baseQuantity && rowMetric == base.quantityMetric;

          if (isSameAsBase && source == 'base') {
            skipped++;
            continue;
          }

          final existingOverride = userByBaseId[baseItemId];

          if (existingOverride == null) {
            final insertedId = await db.into(db.inventoryItems).insert(
                  InventoryItemsCompanion.insert(
                    userId: userId,
                    baseItemId: drift.Value(baseItemId),
                    isOverride: const drift.Value(true),
                    name: drift.Value(rowName),
                    price: drift.Value(rowPrice),
                    baseQuantity: drift.Value(rowQty),
                    quantityMetric: drift.Value(rowMetric),
                    yoloLabel: drift.Value(base.yoloLabel),
                    isSynced: const drift.Value(false),
                  ),
                );
            final created = await (db.select(db.inventoryItems)..where((t) => t.id.equals(insertedId))).getSingleOrNull();
            if (created != null) {
              userByBaseId[baseItemId] = created;
              userById[created.id] = created;
            }
            inserted++;
          } else {
            final updatedRow = existingOverride.copyWith(
              name: drift.Value(rowName),
              price: drift.Value(rowPrice),
              baseQuantity: drift.Value(rowQty),
              quantityMetric: drift.Value(rowMetric),
              isOverride: true,
              isSynced: false,
            );
            await db.update(db.inventoryItems).replace(updatedRow);
            userByBaseId[baseItemId] = updatedRow;
            userById[updatedRow.id] = updatedRow;
            updated++;
          }
          continue;
        }

        final userItemId = _tryParseInt(rowMap['itemId']);
        if (userItemId != null && userById.containsKey(userItemId)) {
          final existing = userById[userItemId]!;
          final updatedRow = existing.copyWith(
            name: drift.Value(rowName),
            price: drift.Value(rowPrice),
            baseQuantity: drift.Value(rowQty),
            quantityMetric: drift.Value(rowMetric),
            isSynced: false,
          );
          await db.update(db.inventoryItems).replace(updatedRow);
          userById[userItemId] = updatedRow;
          updated++;
        } else {
          final insertedId = await db.into(db.inventoryItems).insert(
                InventoryItemsCompanion.insert(
                  userId: userId,
                  name: drift.Value(rowName),
                  price: drift.Value(rowPrice),
                  baseQuantity: drift.Value(rowQty),
                  quantityMetric: drift.Value(rowMetric),
                  isSynced: const drift.Value(false),
                ),
              );
          final created = await (db.select(db.inventoryItems)..where((t) => t.id.equals(insertedId))).getSingleOrNull();
          if (created != null) {
            userById[created.id] = created;
          }
          inserted++;
        }
      } catch (_) {
        failed++;
      }
    }

    return CsvImportResult(inserted: inserted, updated: updated, skipped: skipped, failed: failed);
  }

  Future<List<Map<String, dynamic>>> _getUnifiedInventoryRows() async {
    final sql = '''
      SELECT * FROM (
        SELECT
          COALESCE(si.id, bi.id) as item_id,
          bi.id as base_item_id,
          COALESCE(si.name, bi.name) as name,
          COALESCE(si.price, bi.default_price) as price,
          COALESCE(si.base_quantity, bi.base_quantity) as base_quantity,
          COALESCE(si.quantity_metric, bi.quantity_metric) as quantity_metric,
          bi.yolo_label as yolo_label,
          CASE WHEN si.id IS NOT NULL AND si.is_override = 1 THEN 1 ELSE 0 END as is_override,
          CASE WHEN si.id IS NULL THEN 'base' ELSE 'shop' END as source
        FROM base_inventory_items bi
        LEFT JOIN inventory_items si ON si.base_item_id = bi.id AND si.user_id = ?

        UNION ALL

        SELECT
          si.id as item_id,
          si.base_item_id as base_item_id,
          si.name as name,
          si.price as price,
          si.base_quantity as base_quantity,
          si.quantity_metric as quantity_metric,
          si.yolo_label as yolo_label,
          0 as is_override,
          'shop' as source
        FROM inventory_items si
        WHERE si.user_id = ? AND si.base_item_id IS NULL
      ) as unified
      ORDER BY name ASC
    ''';

    final rows = await db.customSelect(
      sql,
      variables: [
        drift.Variable.withString(userId),
        drift.Variable.withString(userId),
      ],
      readsFrom: {db.baseInventoryItems, db.inventoryItems},
    ).get();

    return rows
        .map(
          (row) => {
            'source': row.read<String>('source'),
            'itemId': row.read<int>('item_id'),
            'baseItemId': row.readNullable<int>('base_item_id'),
            'name': row.readNullable<String>('name') ?? '',
            'price': row.readNullable<double>('price') ?? 0,
            'baseQuantity': row.readNullable<double>('base_quantity') ?? 1,
            'quantityMetric': row.readNullable<String>('quantity_metric') ?? 'pcs',
            'yoloLabel': row.readNullable<String>('yolo_label') ?? '',
            'isOverride': row.read<int>('is_override') == 1,
          },
        )
        .toList();
  }

  Future<String> _pickCsvContent() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty || result.files.single.path == null) {
      throw Exception('No CSV file selected.');
    }

    final pickedFile = File(result.files.single.path!);
    return pickedFile.readAsString();
  }

  Future<String> _shareCsvFile({required String filePrefix, required String csvContent}) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${filePrefix}_$timestamp.csv';
    final filePath = '${tempDir.path}${Platform.pathSeparator}$fileName';
    final file = File(filePath);
    await file.writeAsString(csvContent);

    await SharePlus.instance.share(ShareParams(files: [XFile(filePath)], text: 'Exported $filePrefix CSV'));
    return fileName;
  }

  Map<String, String> _rowToMap(List<String> headers, List<dynamic> row) {
    final result = <String, String>{};
    for (var i = 0; i < headers.length; i++) {
      if (i < row.length) {
        result[headers[i]] = row[i].toString();
      } else {
        result[headers[i]] = '';
      }
    }
    return result;
  }

  double? _tryParseDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  int? _tryParseInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return int.tryParse(value.trim());
  }

  DateTime? _tryParseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  List<Item> _parseItemsJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return <Item>[];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Item.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}

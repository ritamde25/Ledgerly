import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_provider.dart';
import '../core/db/providers.dart';
import '../core/utils/csv_transfer_service.dart';
import '../widgets/inventory_list.dart';

enum _InventoryMenuAction {
  importCsv,
  exportCsv,
}

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    _InventoryMenuAction action,
  ) async {
    final user = ref.read(userProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to use CSV import/export.')),
      );
      return;
    }

    final csvService = CsvTransferService(
      db: ref.read(databaseProvider),
      userId: user.id,
    );

    try {
      if (action == _InventoryMenuAction.exportCsv) {
        final fileName = await csvService.exportInventoryToCsv();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inventory CSV exported: $fileName')),
        );
        return;
      }

      final result = await csvService.importInventoryFromCsv();
      ref.read(syncServiceProvider).syncAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.toSummary('Inventory'))),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inventory CSV action failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Inventory',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton<_InventoryMenuAction>(
            tooltip: 'More options',
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (action) => _handleMenuAction(context, ref, action),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _InventoryMenuAction.importCsv,
                child: Text('Import CSV'),
              ),
              PopupMenuItem(
                value: _InventoryMenuAction.exportCsv,
                child: Text('Export CSV'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 8),
            InventoryList(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/db/daos/inventory_dao.dart';
import '../../core/db/drift_database.dart';
import '../../core/db/models/item.dart';
import '../../core/db/providers.dart';

class AddBillItemSheet extends ConsumerStatefulWidget {
  const AddBillItemSheet({super.key});

  @override
  ConsumerState<AddBillItemSheet> createState() => _AddBillItemSheetState();
}

class _AddBillItemSheetState extends ConsumerState<AddBillItemSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _qtyController;

  bool _addToInventory = false;
  UnifiedInventoryItem? _selectedInventoryItem;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _qtyController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userProvider)?.id ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: 12,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            const Center(
              child: Text(
                'Add Item',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                hintText: 'Search or enter new item',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (_) {
                setState(() {
                  _selectedInventoryItem = null;
                });
              },
            ),
            if (_nameController.text.isNotEmpty && _selectedInventoryItem == null)
              StreamBuilder<List<UnifiedInventoryItem>>(
                stream: ref.watch(inventoryDaoProvider).watchUnifiedInventory(
                      userId,
                      query: _nameController.text,
                      limit: 3,
                    ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: snapshot.data!
                          .map<Widget>(
                            (item) => ListTile(
                              title: Text(
                                item.name,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('₹${item.price.toStringAsFixed(0)}'),
                              onTap: () {
                                setState(() {
                                  _selectedInventoryItem = item;
                                  _nameController.text = item.name;
                                  _priceController.text =
                                      item.price.toStringAsFixed(0);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedInventoryItem == null && _nameController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Checkbox(
                      value: _addToInventory,
                      onChanged: (val) {
                        setState(() {
                          _addToInventory = val ?? false;
                        });
                      },
                      activeColor: Colors.indigo,
                    ),
                    const Expanded(
                      child: Text(
                        'Add to inventory for future use',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addItem,
                style: _buttonStyle(const Color(0xFF1F2937)),
                child: const Text(
                  'Add to Bill',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final qty = int.tryParse(_qtyController.text) ?? 1;

    final newItem = Item(
      name: name,
      price: price,
      quantity: qty,
      baseQuantity: _selectedInventoryItem?.baseQuantity,
      quantityMetric: _selectedInventoryItem?.quantityMetric ?? 'pcs',
    );

    if (_addToInventory && _selectedInventoryItem == null) {
      final userId = ref.read(userProvider)?.id;
      if (userId != null) {
        await ref.read(inventoryDaoProvider).insertItem(
              InventoryItemsCompanion(
                name: Value(name),
                price: Value(price),
                userId: Value(userId),
                baseQuantity: const Value(1.0),
                quantityMetric: const Value('pcs'),
              ),
            );
      }
    }

    if (mounted) {
      Navigator.pop(context, newItem);
    }
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 48,
        height: 5,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
    );
  }
}

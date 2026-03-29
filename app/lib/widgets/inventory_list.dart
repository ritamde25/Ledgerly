import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_provider.dart';
import '../core/db/providers.dart';
import '../core/db/daos/inventory_dao.dart';
import '../core/db/drift_database.dart';
import 'package:drift/drift.dart' as drift;

class InventoryList extends ConsumerStatefulWidget {
  const InventoryList({super.key});

  @override
  ConsumerState<InventoryList> createState() => _InventoryListState();
}

class _InventoryListState extends ConsumerState<InventoryList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(paginatedInventoryProvider);
    final page = ref.watch(inventoryPageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search inventory...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.indigo.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, size: 20, color: Colors.grey.shade400),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(inventorySearchQueryProvider.notifier).state = "";
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      ref.read(inventorySearchQueryProvider.notifier).state = value;
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  onPressed: () => _showEditDialog(context, null),
                  tooltip: 'Add Item',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        inventoryAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No items in inventory',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _InventoryItemCard(
                  item: item,
                  onTap: () => _showEditDialog(context, item),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
        const SizedBox(height: 24),
        _PaginationControls(page: page),
        const SizedBox(height: 100),
      ],
    );
  }

  void _showEditDialog(BuildContext context, UnifiedInventoryItem? item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InventoryEditSheet(item: item),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final UnifiedInventoryItem item;
  final VoidCallback onTap;

  const _InventoryItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.isOverride ? Icons.edit_note_rounded : Icons.inventory_2_rounded,
                    color: Colors.indigo,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.baseQuantity} ${item.quantityMetric}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: Colors.indigo,
                      ),
                    ),
                    if (item.isOverride)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Customized',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaginationControls extends ConsumerWidget {
  final int page;
  const _PaginationControls({required this.page});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageButton(
          icon: Icons.chevron_left_rounded,
          onPressed: page > 0 ? () => ref.read(inventoryPageProvider.notifier).state-- : null,
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Page ${page + 1}',
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _PageButton(
          icon: Icons.chevron_right_rounded,
          onPressed: () => ref.read(inventoryPageProvider.notifier).state++,
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PageButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: onPressed == null ? Colors.grey.shade300 : Colors.indigo,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class InventoryEditSheet extends ConsumerStatefulWidget {
  final UnifiedInventoryItem? item;
  const InventoryEditSheet({super.key, this.item});

  @override
  ConsumerState<InventoryEditSheet> createState() => _InventoryEditSheetState();
}

class _InventoryEditSheetState extends ConsumerState<InventoryEditSheet> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late String selectedMetric;

  final List<String> legalMetrics = ['pcs', 'kg', 'g', 'l', 'ml', 'm', 'cm'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item?.name ?? '');
    priceController = TextEditingController(text: widget.item?.price.toString() ?? '');
    quantityController = TextEditingController(text: widget.item?.baseQuantity.toString() ?? '1.0');
    selectedMetric = widget.item?.quantityMetric ?? 'pcs';
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              item == null ? 'Add New Item' : 'Edit Inventory Item',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: nameController,
              label: 'Item Name',
              icon: Icons.shopping_basket_rounded,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: priceController,
                    label: 'Price',
                    icon: Icons.currency_rupee_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: quantityController,
                    label: 'Quantity',
                    icon: Icons.numbers_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedMetric,
              decoration: InputDecoration(
                labelText: 'Metric',
                labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.straighten_rounded, color: Colors.indigo.shade400),
              ),
              items: legalMetrics.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedMetric = val);
              },
            ),
            if (item?.yoloLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      Text(
                        'AI Label: ${item!.yoloLabel}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final user = ref.read(userProvider);
                final userId = user!.id;

                final name = nameController.text;
                final price = double.tryParse(priceController.text) ?? 0.0;
                final quantity = double.tryParse(quantityController.text) ?? 1.0;

                final dao = ref.read(inventoryDaoProvider);

                if (item == null) {
                  await dao.insertItem(InventoryItemsCompanion.insert(
                    name: drift.Value(name),
                    price: drift.Value(price),
                    userId: userId,
                    baseQuantity: drift.Value(quantity),
                    quantityMetric: drift.Value(selectedMetric),
                  ));
                } else if (item.source == 'base') {
                  await dao.insertItem(InventoryItemsCompanion.insert(
                    userId: userId,
                    baseItemId: drift.Value(int.parse(item.itemId)),
                    isOverride: const drift.Value(true),
                    price: drift.Value(price),
                    baseQuantity: drift.Value(quantity),
                    quantityMetric: drift.Value(selectedMetric),
                    name: drift.Value(name),
                    yoloLabel: drift.Value(item.yoloLabel),
                  ));
                } else {
                  final db = ref.read(databaseProvider);
                  final existing = await (db.select(db.inventoryItems)
                    ..where((t) => t.id.equals(int.parse(item.itemId)))
                  ).getSingle();

                  await dao.updateItem(existing.copyWith(
                    name: drift.Value(name),
                    price: drift.Value(price),
                    baseQuantity: drift.Value(quantity),
                    quantityMetric: drift.Value(selectedMetric),
                    isSynced: false,
                  ));
                }
                
                ref.read(syncServiceProvider).syncAll();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                item == null ? 'Add to Inventory' : 'Save Changes',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icon, color: Colors.indigo.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
    );
  }
}

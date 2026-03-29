import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/db/providers.dart';
import '../core/db/drift_database.dart';
import '../core/db/models/item.dart';
import '../core/auth/auth_provider.dart';
import '../widgets/add_customer_dialog.dart';
import '../core/db/daos/inventory_dao.dart';
import '../services/sync_service.dart';
import 'package:drift/drift.dart' as drift;

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({Key? key}) : super(key: key);

  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  Customer? _selectedCustomer;
  final List<Item> _cart = [];
  
  double get _totalAmount => _cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

  void _addItemToCart(UnifiedInventoryItem inventoryItem) {
    setState(() {
      final index = _cart.indexWhere((item) => item.name == inventoryItem.name);
      if (index >= 0) {
        _cart[index] = Item(
          name: _cart[index].name,
          price: _cart[index].price,
          quantity: _cart[index].quantity + 1,
        );
      } else {
        _cart.add(Item(
          name: inventoryItem.name,
          price: inventoryItem.price,
          quantity: 1,
        ));
      }
    });
  }

  void _removeItemFromCart(int index) {
    setState(() {
      if (_cart[index].quantity > 1) {
        _cart[index] = Item(
          name: _cart[index].name,
          price: _cart[index].price,
          quantity: _cart[index].quantity - 1,
        );
      } else {
        _cart.removeAt(index);
      }
    });
  }

  Future<void> _submitTransaction() async {
    if (_selectedCustomer == null || _cart.isEmpty) return;

    final transactionsDao = ref.read(transactionsDaoProvider);
    final customersDao = ref.read(customersDaoProvider);
    final user = ref.read(userProvider);
    const uuid = Uuid();

    await transactionsDao.insertTransaction(TransactionsCompanion.insert(
      id: uuid.v4(),
      customerId: _selectedCustomer!.id,
      itemsJson: _cart,
      totalAmount: _totalAmount,
      userId: drift.Value(user!.id),
    ));

    await customersDao.updateCustomerDebt(_selectedCustomer!.id, _totalAmount);

    // Trigger sync immediately after local storage
    ref.read(syncServiceProvider).syncAll();

    setState(() {
      _cart.clear();
      _selectedCustomer = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction recorded successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);
    final inventoryAsync = ref.watch(paginatedInventoryProvider);
    final searchQuery = ref.watch(inventorySearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Selection
            customersAsync.when(
              data: (customers) => Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Customer>(
                      value: _selectedCustomer,
                      hint: const Text('Select Customer'),
                      items: customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                      onChanged: (val) => setState(() => _selectedCustomer = val),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () => AddCustomerDialog.show(context),
                  )
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, __) => Center(child: Text('Error loading customers: $err')),
            ),
            const SizedBox(height: 20),
            
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(inventorySearchQueryProvider.notifier).state = "";
                          ref.read(inventoryPageProvider.notifier).state = 0;
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                ref.read(inventorySearchQueryProvider.notifier).state = val;
                ref.read(inventoryPageProvider.notifier).state = 0;
              },
            ),
            const SizedBox(height: 12),
            
            // Inventory Items
            const Text('Select Items', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: inventoryAsync.when(
                data: (items) => items.isEmpty 
                  ? Center(child: Text(searchQuery.isEmpty ? 'Inventory is empty' : 'No items found'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ActionChip(
                            label: Text(item.name),
                            tooltip: '₹${item.price}',
                            avatar: item.source == 'base' 
                                ? const Icon(Icons.public, size: 16) 
                                : const Icon(Icons.store, size: 16),
                            onPressed: () => _addItemToCart(item),
                          ),
                        );
                      },
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, __) => Center(child: Text('Error: $err')),
              ),
            ),
            
            const Divider(height: 32),
            const Text('Cart', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: _cart.isEmpty 
                ? const Center(child: Text('Cart is empty'))
                : ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.name),
                        subtitle: Text('₹${item.price} x ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('₹${(item.price * item.quantity).toStringAsFixed(2)}', 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _removeItemFromCart(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('₹${_totalAmount.toStringAsFixed(2)}', 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: (_selectedCustomer != null && _cart.isNotEmpty) ? _submitTransaction : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Complete Purchase', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

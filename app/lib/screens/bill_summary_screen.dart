import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../core/db/drift_database.dart';
import '../core/db/daos/transactions_dao.dart';
import '../core/db/daos/inventory_dao.dart';
import '../core/db/models/item.dart';
import '../core/db/providers.dart';
import '../core/auth/auth_provider.dart';
import '../widgets/customer_tile.dart';
import 'customer_details_screen.dart';

class BillSummaryScreen extends ConsumerStatefulWidget {
  final TransactionWithCustomer transactionWithCustomer;
  final bool initialIsEditable;

  const BillSummaryScreen({
    Key? key,
    required this.transactionWithCustomer,
    this.initialIsEditable = true,
  }) : super(key: key);

  @override
  ConsumerState<BillSummaryScreen> createState() => _BillSummaryScreenState();
}

class _BillSummaryScreenState extends ConsumerState<BillSummaryScreen> {
  late bool isEditable;
  bool isItemEditingEnabled = false;
  late List<Item> items;
  double discountValue = 0.0;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      isEditable = widget.initialIsEditable;
      items = List.from(widget.transactionWithCustomer.transaction.itemsJson);
      
      double sub = items.fold(0, (sum, item) => sum + (item.price * item.quantity));
      discountValue = (sub - widget.transactionWithCustomer.transaction.totalAmount).clamp(0, double.infinity);
      
      _isInit = false;
    }
  }

  double get subtotal => items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get total => (subtotal - discountValue).clamp(0, double.infinity);

  void _editItemQuantity(int index, bool increase) {
    setState(() {
      final item = items[index];
      final newQty = (item.quantity + (increase ? 1 : -1)).clamp(0, 999);
      if (newQty == 0) {
        items.removeAt(index);
      } else {
        items[index] = item.copyWith(quantity: newQty);
      }
    });
  }

  void _showItemEditSheet(int index) {
    final item = items[index];
    double tempPrice = item.price;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 12, left: 24, right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              const Text('Adjust Price', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
              const SizedBox(height: 8),
              Text(item.name, style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _adjustmentBtn(Icons.remove_rounded, () => setSheetState(() => tempPrice = (tempPrice - 10).clamp(0, 100000)), isRed: true),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      Text('UNIT PRICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.indigo.withOpacity(0.5), letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text('₹${tempPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                    ],
                  ),
                  const SizedBox(width: 24),
                  _adjustmentBtn(Icons.add_rounded, () => setSheetState(() => tempPrice += 10), isGreen: true),
                ],
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _presetBtn(setSheetState, '-₹100', () => tempPrice -= 100),
                  _presetBtn(setSheetState, '-₹50', () => tempPrice -= 50),
                  _presetBtn(setSheetState, '+₹50', () => tempPrice += 50),
                  _presetBtn(setSheetState, '+₹100', () => tempPrice += 100),
                ],
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      items[index] = items[index].copyWith(price: tempPrice);
                    });
                    Navigator.pop(context);
                  },
                  style: _buttonStyle(const Color(0xFF1F2937)),
                  child: const Text('Update Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddItemSheet() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    bool addToInventory = false;
    UnifiedInventoryItem? selectedInventoryItem;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 12, left: 24, right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandle(),
                const Center(child: Text('Add Item', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)))),
                const SizedBox(height: 24),
                
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'Search or enter new item',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: (val) => setSheetState(() {
                    selectedInventoryItem = null;
                  }),
                ),
                
                // Suggestions logic
                if (nameController.text.isNotEmpty && selectedInventoryItem == null)
                  Consumer(
                    builder: (context, ref, _) {
                      final userId = ref.watch(userProvider)?.id ?? '';
                      return StreamBuilder<List<UnifiedInventoryItem>>(
                        stream: ref.watch(inventoryDaoProvider).watchUnifiedInventory(userId, query: nameController.text, limit: 3),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: snapshot.data!.map<Widget>((item) => ListTile(
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text('₹${item.price.toStringAsFixed(0)}'),
                                onTap: () {
                                  setSheetState(() {
                                    selectedInventoryItem = item;
                                    nameController.text = item.name;
                                    priceController.text = item.price.toStringAsFixed(0);
                                  });
                                },
                              )).toList(),
                            ),
                          );
                        }
                      );
                    },
                  ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),

                if (selectedInventoryItem == null && nameController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Checkbox(
                          value: addToInventory,
                          onChanged: (val) => setSheetState(() => addToInventory = val ?? false),
                          activeColor: Colors.indigo,
                        ),
                        const Expanded(child: Text('Add to inventory for future use', style: TextStyle(fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty) return;
                      final price = double.tryParse(priceController.text) ?? 0.0;
                      final qty = int.tryParse(qtyController.text) ?? 1;
                      
                      final newItem = Item(
                        name: nameController.text,
                        price: price,
                        quantity: qty,
                        baseQuantity: selectedInventoryItem?.baseQuantity,
                        quantityMetric: selectedInventoryItem?.quantityMetric ?? 'pcs',
                      );

                      if (addToInventory && selectedInventoryItem == null) {
                        final userId = ref.read(userProvider)?.id;
                        if (userId != null) {
                          await ref.read(inventoryDaoProvider).insertItem(
                            InventoryItemsCompanion(
                              name: Value(nameController.text),
                              price: Value(price),
                              userId: Value(userId),
                              baseQuantity: const Value(1.0),
                              quantityMetric: const Value('pcs'),
                            ),
                          );
                        }
                      }

                      setState(() {
                        items.add(newItem);
                      });
                      Navigator.pop(context);
                    },
                    style: _buttonStyle(const Color(0xFF1F2937)),
                    child: const Text('Add to Bill', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDiscountSheet() {
    double tempDiscount = discountValue;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                const Text('Add Discount', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                const SizedBox(height: 8),
                Text('Adjust absolute cash discount', style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 48),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _adjustmentBtn(Icons.remove_rounded, () => setSheetState(() => tempDiscount = (tempDiscount - 5).clamp(0, subtotal)), isRed: true),
                    const SizedBox(width: 24),
                    Column(
                      children: [
                        Text('CASH DISCOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green.withOpacity(0.5), letterSpacing: 1.5)),
                        Text('₹${tempDiscount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                      ],
                    ),
                    const SizedBox(width: 24),
                    _adjustmentBtn(Icons.add_rounded, () => setSheetState(() => tempDiscount = (tempDiscount + 5).clamp(0, subtotal)), isGreen: true),
                  ],
                ),

                const SizedBox(height: 40),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _quickDiscountBtn(setSheetState, '₹10', () => tempDiscount = (tempDiscount + 10).clamp(0, subtotal)),
                    _quickDiscountBtn(setSheetState, '₹50', () => tempDiscount = (tempDiscount + 50).clamp(0, subtotal)),
                    _quickDiscountBtn(setSheetState, '₹100', () => tempDiscount = (tempDiscount + 100).clamp(0, subtotal)),
                    _quickDiscountBtn(setSheetState, '₹500', () => tempDiscount = (tempDiscount + 500).clamp(0, subtotal)),
                    _quickDiscountBtn(setSheetState, '-₹10', () => tempDiscount = (tempDiscount - 10).clamp(0, subtotal)),
                    _quickDiscountBtn(setSheetState, '-₹50', () => tempDiscount = (tempDiscount - 50).clamp(0, subtotal)),
                    _quickDiscountBtn(setSheetState, 'Clear', () => tempDiscount = 0, isDanger: true),
                  ],
                ),

                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => discountValue = tempDiscount);
                      Navigator.pop(context);
                    },
                    style: _buttonStyle(const Color(0xFF10B981)),
                    child: const Text('Apply Discount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _adjustmentBtn(IconData icon, VoidCallback onTap, {bool isRed = false, bool isGreen = false}) {
    Color color = const Color(0xFF1F2937);
    Color bg = const Color(0xFFF3F4F6);
    if (isRed) { color = Colors.red.shade600; bg = Colors.red.shade50; }
    if (isGreen) { color = Colors.green.shade600; bg = Colors.green.shade50; }

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Icon(icon, size: 24, color: color),
        ),
      ),
    );
  }

  Widget _presetBtn(StateSetter setSheetState, String label, VoidCallback onAction) {
    return InkWell(
      onTap: () => setSheetState(() => onAction()),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF4B5563), fontSize: 14)),
      ),
    );
  }

  Widget _quickDiscountBtn(StateSetter setSheetState, String label, VoidCallback onAction, {bool isDanger = false}) {
    return IntrinsicWidth(
      child: OutlinedButton(
        onPressed: () => setSheetState(() {
          onAction();
        }),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: isDanger ? Colors.red.shade100 : Colors.grey.shade100, width: 1.5),
          backgroundColor: isDanger ? Colors.red.shade50.withOpacity(0.5) : Colors.grey.shade50,
        ),
        child: Text(label, style: TextStyle(color: isDanger ? Colors.red.shade700 : Colors.grey.shade800, fontWeight: FontWeight.w800, fontSize: 14)),
      ),
    );
  }

  Widget _buildHandle() => Center(
    child: Container(
      width: 48, height: 5,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
    ),
  );

  ButtonStyle _buttonStyle(Color color) => ElevatedButton.styleFrom(
    backgroundColor: color, foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    elevation: 0,
  );

  @override
  Widget build(BuildContext context) {
    final customer = widget.transactionWithCustomer.customer;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Bill Summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                  const Spacer(),
                  _buildEditableToggle(),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  CustomerTile(
                    customer: customer,
                    showTrailing: false,
                    showArrow: true,
                    margin: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 20),
                  _buildItemsCard(),
                  const SizedBox(height: 20),
                  _buildFinancialSummary(),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: isEditable ? Colors.indigo.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isEditable ? Colors.indigo.withOpacity(0.2) : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isEditable ? 'EDITING' : 'LOCKED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isEditable ? Colors.indigo : Colors.grey.shade600, letterSpacing: 0.5)),
          const SizedBox(width: 8),
          SizedBox(
            height: 24, width: 44,
            child: Switch(
              value: isEditable,
              onChanged: (val) => setState(() {
                isEditable = val;
                if (!val) isItemEditingEnabled = false;
              }),
              activeColor: Colors.indigo,
              activeTrackColor: Colors.indigo.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Final Total', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey, fontSize: 13)),
                  Text('₹${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                child: Text('SAVED ₹${discountValue.toStringAsFixed(0)}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w900, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isEditable ? () async {
                final previousTotal = widget.transactionWithCustomer.transaction.totalAmount;
                final amountDelta = total - previousTotal;
                final updatedTransaction = widget.transactionWithCustomer.transaction.copyWith(
                  itemsJson: items,
                  totalAmount: total,
                  isSynced: false,
                );
                await ref.read(transactionsDaoProvider).updateTransaction(updatedTransaction);
                if (amountDelta != 0) {
                  await ref.read(customersDaoProvider).updateCustomerDebt(
                    widget.transactionWithCustomer.customer.id,
                    amountDelta,
                  );
                }
                ref.read(syncServiceProvider).syncAll();
                if (mounted) Navigator.pop(context);
              } : null,
              style: _buttonStyle(isEditable ? const Color(0xFF6366F1) : Colors.grey.shade300),
              child: Text(
                isEditable ? 'Confirm & Save Bill' : 'Bill is Locked',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
            child: Row(
              children: [
                const Text('Bill Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                const Spacer(),
                if (isEditable) ...[
                  IconButton(
                    onPressed: _showAddItemSheet,
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.indigo.shade50, shape: BoxShape.circle),
                      child: const Icon(Icons.add_rounded, color: Colors.indigo, size: 20),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => isItemEditingEnabled = !isItemEditingEnabled),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isItemEditingEnabled ? const Color(0xFF1F2937) : Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(isItemEditingEnabled ? Icons.check_rounded : Icons.edit_note_rounded,
                               size: 18, color: isItemEditingEnabled ? Colors.white : Colors.indigo),
                          const SizedBox(width: 6),
                          Text(isItemEditingEnabled ? 'Done' : 'Edit',
                               style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isItemEditingEnabled ? Colors.white : Colors.indigo)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 24, endIndent: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade50, indent: 24, endIndent: 24),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: isItemEditingEnabled ? () => _showItemEditSheet(index) : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF374151))),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('₹${item.price.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w700)),
                                Text(' × ${item.quantity}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isItemEditingEnabled)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF3F4F6))),
                        child: Row(
                          children: [
                            _qtyBtn(Icons.remove_rounded, () => _editItemQuantity(index, false), Colors.red.shade400),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1F2937))),
                            ),
                            _qtyBtn(Icons.add_rounded, () => _editItemQuantity(index, true), Colors.green.shade400),
                          ],
                        ),
                      )
                    else
                      Text('₹${(item.price * item.quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1F2937))),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, size: 20, color: color)),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 18),
          _summaryRow(
            'Discount',
            '- ₹${discountValue.toStringAsFixed(0)}',
            color: const Color(0xFF10B981),
            onTap: isEditable ? _showDiscountSheet : null,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1, color: Color(0xFFF3F4F6))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.grey)),
              Text('₹${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                if (onTap != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: (color ?? Colors.indigo).withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.edit_rounded, size: 10, color: color ?? Colors.indigo),
                  ),
                ],
              ],
            ),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color ?? const Color(0xFF1F2937))),
          ],
        ),
      ),
    );
  }
}

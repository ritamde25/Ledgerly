import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/drift_database.dart';
import '../core/db/daos/transactions_dao.dart';
import '../core/db/models/item.dart';
import '../core/db/providers.dart';
import '../widgets/popups/add_bill_item_sheet.dart';
import '../widgets/popups/customer_tile.dart';
import '../widgets/popups/discount_sheet.dart';
import '../widgets/popups/item_price_edit_sheet.dart';

class BillSummaryScreen extends ConsumerStatefulWidget {
  final TransactionWithCustomer transactionWithCustomer;
  final bool initialIsEditable;

  const BillSummaryScreen({
    Key? key,
    required this.transactionWithCustomer,
    this.initialIsEditable = false,
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

  Future<void> _showItemEditSheet(int index) async {
    final updatedPrice = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemPriceEditSheet(item: items[index]),
    );

    if (!mounted || updatedPrice == null || index >= items.length) {
      return;
    }

    setState(() {
      items[index] = items[index].copyWith(price: updatedPrice);
    });
  }

  Future<void> _showAddItemSheet() async {
    final newItem = await showModalBottomSheet<Item>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddBillItemSheet(),
    );

    if (!mounted || newItem == null) {
      return;
    }

    setState(() {
      items.add(newItem);
    });
  }

  Future<void> _showDiscountSheet() async {
    final updatedDiscount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DiscountSheet(
        initialDiscount: discountValue,
        subtotal: subtotal,
      ),
    );

    if (!mounted || updatedDiscount == null) {
      return;
    }

    setState(() {
      discountValue = updatedDiscount;
    });
  }

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

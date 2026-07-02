import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/daos/transactions_dao.dart';
import '../core/db/models/item.dart';
import '../core/db/providers.dart';
import '../widgets/billing/bill_summary_header.dart';
import '../widgets/billing/bill_summary_items_card.dart';
import '../widgets/billing/billing_bottom_bar.dart';
import '../widgets/billing/financial_summary.dart';
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

  Future<void> _saveBill() async {
    final previousTotal = widget.transactionWithCustomer.transaction.totalAmount;
    final amountDelta = total - previousTotal;
    final updatedTransaction =
        widget.transactionWithCustomer.transaction.copyWith(
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
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.transactionWithCustomer.customer;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            BillSummaryHeader(
              isEditable: isEditable,
              onBackPressed: () => Navigator.pop(context),
              onEditableChanged: (val) => setState(() {
                isEditable = val;
                if (!val) {
                  isItemEditingEnabled = false;
                }
              }),
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
                  BillSummaryItemsCard(
                    items: items,
                    isEditable: isEditable,
                    isItemEditingEnabled: isItemEditingEnabled,
                    onAddItem: _showAddItemSheet,
                    onToggleItemEditing: () {
                      setState(() {
                        isItemEditingEnabled = !isItemEditingEnabled;
                      });
                    },
                    onEditItemPrice: _showItemEditSheet,
                    onEditItemQuantity: _editItemQuantity,
                  ),
                  const SizedBox(height: 20),
                  FinancialSummary(
                    subtotal: subtotal,
                    discountValue: discountValue,
                    totalAmount: total,
                    onEditDiscount: isEditable ? _showDiscountSheet : null,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            BillingBottomBar(
              totalAmount: total,
              discountValue: discountValue,
              canSubmit: isEditable,
              isSubmitting: false,
              isUpfront: false,
              disabledButtonLabel: 'Bill is Locked',
              onSubmit: _saveBill,
            ),
          ],
        ),
      ),
    );
  }
}

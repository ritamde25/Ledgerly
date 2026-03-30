import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/db/providers.dart';
import '../core/db/drift_database.dart';
import '../core/db/models/item.dart';
import '../core/auth/auth_provider.dart';
import '../widgets/popups/add_customer_dialog.dart';
import '../core/db/daos/inventory_dao.dart';
import '../widgets/popups/discount_sheet.dart';
import '../widgets/billing/customer_selector.dart';
import '../widgets/billing/inventory_card.dart';
import '../widgets/billing/cart_card.dart';
import '../widgets/billing/financial_summary.dart';
import '../widgets/billing/payment_mode_card.dart';
import '../widgets/billing/billing_bottom_bar.dart';
import 'package:drift/drift.dart' as drift;

typedef PaymentModeEnum = PaymentMode;

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({
    super.key,
    this.detectedLabelCounts = const {},
    this.sourceImageCount = 0,
  });

  final Map<String, int> detectedLabelCounts;
  final int sourceImageCount;

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  String? _selectedCustomerId;
  PaymentModeEnum _paymentMode = PaymentModeEnum.credit;
  bool _isSubmitting = false;
  final List<Item> _cart = [];
  double _discountValue = 0.0;
  String _customerSearchQuery = '';
  final TextEditingController _customerSearchController = TextEditingController();
  bool _hasAppliedDetectedItems = false;

  double get _subtotal =>
      _cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get _totalAmount =>
      (_subtotal - _discountValue).clamp(0, double.infinity);

  @override
  void initState() {
    super.initState();
    _applyDetectedItemsIfAny();
  }

  @override
  void dispose() {
    _customerSearchController.dispose();
    super.dispose();
  }

  Future<void> _applyDetectedItemsIfAny() async {
    if (_hasAppliedDetectedItems || widget.detectedLabelCounts.isEmpty) {
      return;
    }

    _hasAppliedDetectedItems = true;

    final user = ref.read(userProvider);
    if (user == null) {
      return;
    }

    final inventoryDao = ref.read(inventoryDaoProvider);
    final allItems = await inventoryDao.getUnifiedInventory(user.id);

    if (!mounted) {
      return;
    }

    final byYoloLabel = <String, UnifiedInventoryItem>{
      for (final item in allItems)
        if ((item.yoloLabel ?? '').trim().isNotEmpty)
          _normalize(item.yoloLabel!): item,
    };
    final byName = <String, UnifiedInventoryItem>{
      for (final item in allItems) _normalize(item.name): item,
    };

    int matchedCount = 0;
    final unmatched = <String>[];

    setState(() {
      for (final entry in widget.detectedLabelCounts.entries) {
        final normalizedLabel = _normalize(entry.key);
        final quantity = entry.value;
        if (quantity <= 0) {
          continue;
        }

        final inventoryMatch = byYoloLabel[normalizedLabel] ?? byName[normalizedLabel];
        if (inventoryMatch == null) {
          unmatched.add(entry.key);
          continue;
        }

        matchedCount += quantity;

        final cartIndex = _cart.indexWhere((item) => item.name == inventoryMatch.name);
        if (cartIndex >= 0) {
          _cart[cartIndex] = _cart[cartIndex].copyWith(
            quantity: _cart[cartIndex].quantity + quantity,
          );
        } else {
          _cart.add(Item(
            name: inventoryMatch.name,
            price: inventoryMatch.price,
            quantity: quantity,
            baseQuantity: inventoryMatch.baseQuantity,
            quantityMetric: inventoryMatch.quantityMetric,
          ));
        }
      }
    });

    if (!mounted) {
      return;
    }

    if (matchedCount > 0) {
      final imagePart = widget.sourceImageCount > 0 ? ' from ${widget.sourceImageCount} image(s)' : '';
      final unmatchedPart = unmatched.isNotEmpty ? ' ${unmatched.length} label(s) were not found in inventory.' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $matchedCount detected item(s)$imagePart.$unmatchedPart')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No detected labels matched your inventory. You can still bill manually.'),
        ),
      );
    }
  }

  String _normalize(String value) => value.trim().toLowerCase();

  void _addItemToCart(UnifiedInventoryItem inventoryItem) {
    setState(() {
      final index = _cart.indexWhere((item) => item.name == inventoryItem.name);
      if (index >= 0) {
        _cart[index] =
            _cart[index].copyWith(quantity: _cart[index].quantity + 1);
      } else {
        _cart.add(Item(
          name: inventoryItem.name,
          price: inventoryItem.price,
          quantity: 1,
        ));
      }
    });
  }

  void _addCustomItemToCart(Item item) {
    setState(() {
      final index = _cart.indexWhere((cartItem) => cartItem.name == item.name);
      if (index >= 0) {
        _cart[index] = _cart[index].copyWith(
            quantity: _cart[index].quantity + item.quantity);
      } else {
        _cart.add(item);
      }
    });
  }

  void _decreaseItemQuantity(int index) {
    setState(() {
      if (_cart[index].quantity > 1) {
        _cart[index] =
            _cart[index].copyWith(quantity: _cart[index].quantity - 1);
      } else {
        _cart.removeAt(index);
      }
    });
  }

  void _increaseItemQuantity(int index) {
    setState(() {
      _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity + 1);
    });
  }

  Future<void> _showDiscountSheet() async {
    final updatedDiscount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          DiscountSheet(
            initialDiscount: _discountValue,
            subtotal: _subtotal,
          ),
    );

    if (!mounted || updatedDiscount == null) {
      return;
    }

    setState(() {
      _discountValue = updatedDiscount;
    });
  }

  void _onPaymentModeChanged(PaymentModeEnum mode) {
    setState(() {
      _paymentMode = mode;
    });
  }

  void _onCustomerSelected(String customerId) {
    setState(() {
      _selectedCustomerId = customerId;
      _customerSearchQuery = '';
    });
  }

  void _onClearCustomerSelection() {
    setState(() {
      _customerSearchQuery = '';
      _selectedCustomerId = null;
      _customerSearchController.clear();
    });
  }

  void _onCustomerSearchChanged(String value) {
    setState(() {
      _customerSearchQuery = value;
      _selectedCustomerId = null;
    });
  }

  Future<void> _submitTransaction() async {
    if (_selectedCustomerId == null || _cart.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final transactionsDao = ref.read(transactionsDaoProvider);
      final customersDao = ref.read(customersDaoProvider);
      final user = ref.read(userProvider);
      const uuid = Uuid();
      final total = _totalAmount;
      final selectedPaymentMode = _paymentMode;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found. Please log in again.')),
        );
        return;
      }

      if (selectedPaymentMode == PaymentModeEnum.upfront) {
        await transactionsDao.insertTransaction(
          TransactionsCompanion.insert(
            id: uuid.v4(),
            customerId: _selectedCustomerId!,
            itemsJson: const <Item>[],
            totalAmount: total,
            userId: drift.Value(user.id),
          ),
        );

        await transactionsDao.insertTransaction(TransactionsCompanion.insert(
          id: uuid.v4(),
          customerId: _selectedCustomerId!,
          itemsJson: _cart,
          totalAmount: total,
          userId: drift.Value(user.id),
        ));
      } else {
        await transactionsDao.insertTransaction(TransactionsCompanion.insert(
          id: uuid.v4(),
          customerId: _selectedCustomerId!,
          itemsJson: _cart,
          totalAmount: total,
          userId: drift.Value(user.id),
        ));

        await customersDao.updateCustomerDebt(_selectedCustomerId!, total);
      }

      ref.read(syncServiceProvider).syncAll();

      setState(() {
        _cart.clear();
        _selectedCustomerId = null;
        _paymentMode = PaymentModeEnum.credit;
        _discountValue = 0.0;
        _customerSearchQuery = '';
        _customerSearchController.clear();
      });

      final message = selectedPaymentMode == PaymentModeEnum.upfront
          ? 'Bill and payment recorded successfully.'
          : 'Bill recorded on credit successfully.';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save bill: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'Create Bill',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Add customer',
                    onPressed: () => AddCustomerDialog.show(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                          Icons.person_add_alt_1_rounded, color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  CustomerSelector(
                    selectedCustomerId: _selectedCustomerId,
                    searchQuery: _customerSearchQuery,
                    searchController: _customerSearchController,
                    onSearchChanged: _onCustomerSearchChanged,
                    onCustomerSelected: _onCustomerSelected,
                    onClearSelection: _onClearCustomerSelection,
                  ),
                  const SizedBox(height: 16),
                  InventoryCard(
                    onItemAdded: _addItemToCart,
                    onCustomItemAdded: _addCustomItemToCart,
                  ),
                  const SizedBox(height: 16),
                  CartCard(
                    cart: _cart,
                    onDecreaseQuantity: _decreaseItemQuantity,
                    onIncreaseQuantity: _increaseItemQuantity,
                    onRemoveItem: (index) => _decreaseItemQuantity(index),
                  ),
                  const SizedBox(height: 16),
                  if (_cart.isNotEmpty) ...[
                    FinancialSummary(
                      subtotal: _subtotal,
                      discountValue: _discountValue,
                      totalAmount: _totalAmount,
                      onEditDiscount: _showDiscountSheet,
                    ),
                    const SizedBox(height: 16),
                  ],
                  PaymentModeCard(
                    selectedMode: _paymentMode,
                    onModeChanged: _onPaymentModeChanged,
                  ),
                ],
              ),
            ),
            BillingBottomBar(
              totalAmount: _totalAmount,
              discountValue: _discountValue,
              canSubmit: _selectedCustomerId != null && _cart.isNotEmpty &&
                  !_isSubmitting,
              isSubmitting: _isSubmitting,
              isUpfront: _paymentMode == PaymentModeEnum.upfront,
              onSubmit: _submitTransaction,
            ),
          ],
        ),
      ),
    );
  }
}
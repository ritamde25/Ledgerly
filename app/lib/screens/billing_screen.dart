import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../widgets/add_customer_dialog.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({Key? key}) : super(key: key);

  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _formKey = GlobalKey<FormState>();
  Customer? _selectedCustomer;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.debit;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_formKey.currentState!.validate() && _selectedCustomer != null) {
      final amount = double.parse(_amountController.text);
      final note = _noteController.text;

      Provider.of<AppState>(context, listen: false).addTransaction(
        _selectedCustomer!,
        amount,
        note,
        _type,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('${_type == TransactionType.debit ? "Purchase" : "Payment"} recorded!'),
            ],
          ),
          backgroundColor: _type == TransactionType.debit ? Colors.indigo : Colors.green.shade700,
        ),
      );

      _amountController.clear();
      _noteController.clear();
      setState(() {
        _selectedCustomer = null;
        _type = TransactionType.debit;
      });
    }
  }

  Future<void> _addNewCustomer() async {
    final newCustomer = await AddCustomerDialog.show(context);
    if (newCustomer != null) {
      setState(() {
        _selectedCustomer = newCustomer;
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.indigo.shade400, size: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final customers = appState.customers;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('New Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Transaction Type Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildTypeTab(TransactionType.debit, 'Purchase', Icons.shopping_basket_outlined),
                      _buildTypeTab(TransactionType.credit, 'Payment', Icons.account_balance_wallet_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Form Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Customer Dropdown
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<Customer>(
                              value: _selectedCustomer,
                              isExpanded: true,
                              decoration: _inputDecoration('Select Customer', Icons.person_outline),
                              items: customers.map((customer) {
                                return DropdownMenuItem(
                                  value: customer,
                                  child: Text(customer.name),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedCustomer = value),
                              validator: (value) => value == null ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: _addNewCustomer,
                              icon: const Icon(Icons.person_add_alt_1, color: Colors.indigo),
                              tooltip: 'Add Customer',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Amount Field
                      TextFormField(
                        controller: _amountController,
                        decoration: _inputDecoration(
                          _type == TransactionType.debit ? 'Amount to Collect' : 'Amount Received',
                          Icons.currency_rupee,
                        ),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter amount';
                          if (double.tryParse(value) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Note Field
                      TextFormField(
                        controller: _noteController,
                        decoration: _inputDecoration('Add a note (items, details...)', Icons.edit_note),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == TransactionType.debit ? Colors.indigo : Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_type == TransactionType.debit ? Icons.add_shopping_cart : Icons.done_all),
                      const SizedBox(width: 10),
                      Text(
                        _type == TransactionType.debit ? 'Save Purchase' : 'Record Payment',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab(TransactionType type, String label, IconData icon) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? (type == TransactionType.debit ? Colors.indigo : Colors.green.shade700) : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

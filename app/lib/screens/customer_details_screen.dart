import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/db/providers.dart';
import '../core/db/drift_database.dart';
import '../widgets/record_payment_dialog.dart';
import '../widgets/transaction_card.dart';
import '../core/db/daos/transactions_dao.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  final int customerId;

  const CustomerDetailsScreen({Key? key, required this.customerId}) : super(key: key);

  void _showEditCustomerDialog(BuildContext context, WidgetRef ref, Customer customer) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 12,
          left: 24,
          right: 24,
        ),
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
            const Text(
              'Edit Customer Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(Icons.person_rounded, color: Colors.indigo.shade400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(Icons.phone_rounded, color: Colors.indigo.shade400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final customersDao = ref.read(customersDaoProvider);
                await customersDao.updateCustomer(customer.copyWith(
                  name: nameController.text,
                  phone: phoneController.text,
                  isSynced: false,
                ));
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
              child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditDueDialog(BuildContext context, WidgetRef ref, Customer customer) {
    final dueController = TextEditingController(text: customer.totalDue.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 12,
          left: 24,
          right: 24,
        ),
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
            const Text(
              'Update Due Amount',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 8),
            Text(
              'Manually adjust the total outstanding balance for this customer.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: dueController,
              decoration: InputDecoration(
                labelText: 'Total Due',
                labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(Icons.currency_rupee_rounded, color: Colors.indigo.shade400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(dueController.text);
                if (amount != null) {
                  final customersDao = ref.read(customersDaoProvider);
                  await customersDao.updateCustomer(customer.copyWith(
                    totalDue: amount,
                    isSynced: false,
                  ));
                  ref.read(syncServiceProvider).syncAll();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Save Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Customer customer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_forever_rounded, color: Colors.red.shade600, size: 32),
            ),
            const SizedBox(height: 20),
            const Text(
              'Delete Customer?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to delete ${customer.name}? All transaction history for this customer will be permanently removed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final dao = ref.read(customersDaoProvider);
                      await dao.deleteCustomer(customer);
                      ref.read(syncServiceProvider).syncAll();
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.pop(context); // Go back to customers list
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Delete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendSmsReminder(Customer customer) {
    // Placeholder function
    print('Sending SMS reminder to ${customer.phone}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerProvider(customerId));
    final transactionsAsync = ref.watch(customerTransactionsProvider(customerId));
    
    return customerAsync.when(
      data: (customer) {
        if (customer == null) return const Scaffold(body: Center(child: Text('Customer not found')));

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                Text(customer.phone, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            actions: [
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF1F2937)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit_name', child: Text('Edit Name & Phone')),
                  const PopupMenuItem(value: 'edit_due', child: Text('Edit Due Amount')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete Customer', style: TextStyle(color: Colors.red))),
                ],
                onSelected: (value) {
                  if (value == 'edit_name') _showEditCustomerDialog(context, ref, customer);
                  if (value == 'edit_due') _showEditDueDialog(context, ref, customer);
                  if (value == 'delete') _confirmDelete(context, ref, customer);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: customer.totalDue >= 0 ?
                    [const Color(0xFF4F46E5), const Color(0xFF312E81)] :
                    [const Color(0xFF10B981), const Color(0xFF064E3B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: (customer.totalDue >= 0 ? const Color(0xFF4F46E5) : const Color(0xFF10B981)).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      customer.totalDue >= 0 ? 'TOTAL DUE' : 'ADVANCE BALANCE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${customer.totalDue.abs().toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => RecordPaymentDialog.show(context, ref, customer),
                            icon: const Icon(Icons.add_card, size: 18),
                            label: const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: customer.totalDue >= 0 ? const Color(0xFF312E81) : const Color(0xFF064E3B),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _sendSmsReminder(customer),
                            icon: const Icon(Icons.message_rounded, color: Colors.white, size: 18),
                            label: const Text('Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    const Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Recent First',
                        style: TextStyle(
                          color: Colors.indigo.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: transactionsAsync.when(
                  data: (transactions) => transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final tx = transactions[index];
                              return TransactionCard(
                                transactionWithCustomer: TransactionWithCustomer(tx, customer),
                                showCustomerName: false,
                              );
                            },
                          ),
                      ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, __) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, __) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

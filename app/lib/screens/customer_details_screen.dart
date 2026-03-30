import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/providers.dart';
import '../core/db/drift_database.dart';
import '../core/auth/auth_provider.dart';
import '../core/utils/send_sms.dart';
import '../widgets/popups/delete_customer_dialog.dart';
import '../widgets/popups/edit_customer_dialog.dart';
import '../widgets/popups/edit_due_dialog.dart';
import '../widgets/popups/record_payment_dialog.dart';
import '../widgets/transaction_card.dart';
import '../core/db/daos/transactions_dao.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailsScreen({Key? key, required this.customerId}) : super(key: key);

  Future<void> _sendSmsReminder(BuildContext context, WidgetRef ref, Customer customer) async {
    if (customer.phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer phone number is missing.')),
      );
      return;
    }

    if (customer.totalDue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No due amount to remind for this customer.')),
      );
      return;
    }

    final user = ref.read(userProvider);
    final storeName = (user?.userMetadata?['display_name'] as String?)?.trim().isNotEmpty == true
        ? (user!.userMetadata?['display_name'] as String).trim()
        : user!.email!.split('@')[0];

    final opened = await SmsReminderService.sendPersonalizedReminder(
      customerName: customer.name,
      phone: customer.phone,
      dueAmount: customer.totalDue,
      storeName: storeName,
    );

    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (opened) {
      messenger.showSnackBar(
        SnackBar(content: Text('Opening SMS draft for ${customer.name}.')),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open SMS app.')),
      );
    }
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
                  if (value == 'edit_name') EditCustomerDialog.show(context, ref, customer);
                  if (value == 'edit_due') EditDueDialog.show(context, ref, customer);
                  if (value == 'delete') DeleteCustomerDialog.show(context, ref, customer);
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
                            onPressed: () => _sendSmsReminder(context, ref, customer),
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

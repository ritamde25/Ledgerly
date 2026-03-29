import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../core/db/providers.dart';
import '../core/db/drift_database.dart';
import '../core/auth/auth_provider.dart';

class RecordPaymentDialog {
  static void show(BuildContext context, WidgetRef ref, Customer customer) {
    final amountController = TextEditingController();

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
            Text(
              'Payment from ${customer.name}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Current Due: ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                Text(
                  '₹${customer.totalDue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(Icons.currency_rupee_rounded, color: Colors.indigo.shade400),
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
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  final customersDao = ref.read(customersDaoProvider);
                  final transactionsDao = ref.read(transactionsDaoProvider);
                  final user = ref.read(userProvider);

                  // Update debt
                  await customersDao.updateCustomerDebt(customer.id, -amount);
                  
                  // Record as a transaction
                  await transactionsDao.insertTransaction(TransactionsCompanion.insert(
                    customerId: customer.id,
                    itemsJson: [], // Empty items list signifies a payment
                    totalAmount: amount,
                    userId: drift.Value(user!.id),
                  ));

                  ref.read(syncServiceProvider).syncAll();
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), // Emerald
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                'Confirm Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

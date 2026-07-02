import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../core/db/providers.dart';
import '../../core/db/drift_database.dart';
import '../../core/auth/auth_provider.dart';

class RecordPaymentDialog {
  static void show(BuildContext context, WidgetRef ref, Customer customer) {
    final amountController = TextEditingController();
    double tempAmount = 0;

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
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 12,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHandle(),
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
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _adjustmentBtn(
                    Icons.remove_rounded,
                    () {
                      setSheetState(() {
                        tempAmount = (tempAmount - 10).clamp(0, double.infinity);
                        amountController.text = tempAmount.toStringAsFixed(0);
                      });
                    },
                    isRed: true,
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      Text(
                        'PAYMENT AMOUNT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.indigo.withOpacity(0.5),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${tempAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  _adjustmentBtn(
                    Icons.add_rounded,
                    () {
                      setSheetState(() {
                        tempAmount += 10;
                        amountController.text = tempAmount.toStringAsFixed(0);
                      });
                    },
                    isGreen: true,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _quickAmountBtn('+₹50', () {
                    setSheetState(() {
                      tempAmount += 50;
                      amountController.text = tempAmount.toStringAsFixed(0);
                    });
                  }),
                  _quickAmountBtn('+₹100', () {
                    setSheetState(() {
                      tempAmount += 100;
                      amountController.text = tempAmount.toStringAsFixed(0);
                    });
                  }),
                  _quickAmountBtn('+₹500', () {
                    setSheetState(() {
                      tempAmount += 500;
                      amountController.text = tempAmount.toStringAsFixed(0);
                    });
                  }),
                  _quickAmountBtn('+₹1000', () {
                    setSheetState(() {
                      tempAmount += 1000;
                      amountController.text = tempAmount.toStringAsFixed(0);
                    });
                  }),
                  _quickAmountBtn('Clear', () {
                    setSheetState(() {
                      tempAmount = 0;
                      amountController.text = '';
                    });
                  }, isDanger: true),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Or type amount manually',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: Icon(
                    Icons.edit_rounded,
                    color: Colors.indigo.shade400,
                  ),
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
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    setSheetState(() {
                      tempAmount = parsed.clamp(0, double.infinity);
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? tempAmount;
                  if (amount > 0) {
                    final customersDao = ref.read(customersDaoProvider);
                    final transactionsDao = ref.read(transactionsDaoProvider);
                    final user = ref.read(userProvider);
                    const uuid = Uuid();

                    await customersDao.updateCustomerDebt(customer.id, -amount);

                    await transactionsDao.insertTransaction(
                      TransactionsCompanion.insert(
                        id: uuid.v4(),
                        customerId: customer.id,
                        itemsJson: [],
                        totalAmount: amount,
                        userId: drift.Value(user!.id),
                      ),
                    );

                    ref.read(syncServiceProvider).syncAll();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
      ),
    ).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 250), () {
          amountController.dispose();
        });
      });
    });
  }

  static Widget _adjustmentBtn(
    IconData icon,
    VoidCallback onTap, {
    bool isRed = false,
    bool isGreen = false,
  }) {
    Color color = const Color(0xFF1F2937);
    Color bg = const Color(0xFFF3F4F6);

    if (isRed) {
      color = Colors.red.shade600;
      bg = Colors.red.shade50;
    }
    if (isGreen) {
      color = Colors.green.shade600;
      bg = Colors.green.shade50;
    }

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

  static Widget _quickAmountBtn(
    String label,
    VoidCallback onAction, {
    bool isDanger = false,
  }) {
    return IntrinsicWidth(
      child: OutlinedButton(
        onPressed: onAction,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(
            color: isDanger ? Colors.red.shade100 : Colors.grey.shade100,
            width: 1.5,
          ),
          backgroundColor:
              isDanger ? Colors.red.shade50.withOpacity(0.5) : Colors.grey.shade50,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDanger ? Colors.red.shade700 : Colors.grey.shade800,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

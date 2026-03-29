import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/db/daos/transactions_dao.dart';

class TransactionCard extends StatelessWidget {
  final TransactionWithCustomer transactionWithCustomer;
  final bool showCustomerName;

  const TransactionCard({
    Key? key, 
    required this.transactionWithCustomer,
    this.showCustomerName = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transaction = transactionWithCustomer.transaction;
    final customer = transactionWithCustomer.customer;
    
    final items = transaction.itemsJson;
    final isPayment = items.isEmpty;
    
    final statusColor = isPayment 
        ? const Color(0xFF10B981) // Emerald
        : const Color(0xFFEF4444); // Red
    
    final bgColor = isPayment 
        ? const Color(0xFF10B981).withOpacity(0.1) 
        : const Color(0xFFEF4444).withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Optional: Show transaction details
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isPayment ? Icons.account_balance_wallet_rounded : Icons.shopping_bag_rounded,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showCustomerName) ...[
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (!showCustomerName && !isPayment) ...[
                         Text(
                          items.map((i) => '${i.quantity}x ${i.name}').join(', '),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (!showCustomerName && isPayment) ...[
                        const Text(
                          'Payment Received',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM, hh:mm a').format(transaction.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      if (showCustomerName && items.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          items.map((i) => '${i.quantity}x ${i.name}').join(', '),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '₹${transaction.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

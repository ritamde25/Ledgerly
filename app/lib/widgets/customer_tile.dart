import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onPayment;

  const CustomerTile({Key? key, required this.customer, this.onTap, this.onPayment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNegative = customer.totalDue < 0;
    final isZero = customer.totalDue == 0;
    final absDue = customer.totalDue.abs();
    
    final statusColor = isNegative 
        ? Colors.green 
        : (isZero ? Colors.grey.shade600 : Colors.red.shade700);
    
    final bgColor = isNegative 
        ? Colors.green.shade50 
        : (isZero ? Colors.grey.shade50 : Colors.red.shade50);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    customer.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Colors.indigo.shade900, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isNegative ? 'Advance' : (isZero ? 'Settled' : 'Due'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${absDue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    if (onPayment != null && !isZero) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: onPayment,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 14, color: Colors.white),
                              Text(
                                ' Pay',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

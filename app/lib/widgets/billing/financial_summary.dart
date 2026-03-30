import 'package:flutter/material.dart';

class FinancialSummary extends StatelessWidget {
  final double subtotal;
  final double discountValue;
  final double totalAmount;
  final VoidCallback onEditDiscount;

  const FinancialSummary({
    Key? key,
    required this.subtotal,
    required this.discountValue,
    required this.totalAmount,
    required this.onEditDiscount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 16),
          _summaryRow(
            'Discount',
            '- ₹${discountValue.toStringAsFixed(0)}',
            color: const Color(0xFF10B981),
            onTap: onEditDiscount,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              color: Color(0xFFF3F4F6),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                ),
              ),
              Text(
                '₹${totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: (color ?? Colors.indigo).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 10,
                      color: color ?? Colors.indigo,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color ?? const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/db/drift_database.dart';
import '../../screens/customer_details_screen.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;
  final bool showTrailing;
  final bool showArrow;
  final VoidCallback? onTap;
  final EdgeInsets? margin;

  const CustomerTile({
    super.key,
    required this.customer,
    this.showTrailing = true,
    this.showArrow = true,
    this.onTap,
    this.margin,
  });

  String _getInitials(String name) {
    List<String> names = name.trim().split(" ");
    if (names.length >= 2) {
      return (names[0][0] + names[1][0]).toUpperCase();
    } else if (names.isNotEmpty && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return "?";
  }

  String formatPhone(String phone) {
    if (phone.length <= 5) return phone; // basic safety

    return "+91 ${phone.substring(0, 5)} ${phone.substring(5)}";
  }

  Color _getDeterministicColor(String id) {
    final List<Color> modernColors = [
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFF97316),
      const Color(0xFF06B6D4),
      const Color(0xFF84CC16),
      const Color(0xFFEF4444),
    ];

    int hash = 0;
    for (int i = 0; i < id.length; i++) {
      hash = (hash * 31 + id.codeUnitAt(i)) & 0x7fffffff;
    }

    return modernColors[hash % modernColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isNegative = customer.totalDue < 0;
    final isZero = customer.totalDue == 0;
    final absDue = customer.totalDue.abs();
    
    final statusColor = isNegative || isZero
        ? const Color(0xFF10B981) // Emerald/Green
        : const Color(0xFFEF4444); // Red

    final avatarColor = _getDeterministicColor(customer.name + customer.phone);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          onTap: onTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerDetailsScreen(customerId: customer.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: avatarColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(customer.name),
                      style: TextStyle(
                        color: avatarColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatPhone(customer.phone),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showTrailing)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isZero ? "PAID" : "₹${absDue.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        isNegative ? "Advance" : (isZero ? "No Due" : "Due"),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  )
                else if (showArrow)
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

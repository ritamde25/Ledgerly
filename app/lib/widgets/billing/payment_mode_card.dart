import 'package:flutter/material.dart';

enum PaymentMode { credit, upfront }

class PaymentModeCard extends StatelessWidget {
  final PaymentMode selectedMode;
  final Function(PaymentMode) onModeChanged;

  const PaymentModeCard({
    Key? key,
    required this.selectedMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Mode',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _paymentModeCard(
                  title: 'Paid on Credit',
                  subtitle: 'Adds to debt',
                  icon: Icons.schedule_rounded,
                  selected: selectedMode == PaymentMode.credit,
                  onTap: () => onModeChanged(PaymentMode.credit),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _paymentModeCard(
                  title: 'Paid Up Front',
                  subtitle: 'Direct payment',
                  icon: Icons.payments_rounded,
                  selected: selectedMode == PaymentMode.upfront,
                  onTap: () => onModeChanged(PaymentMode.upfront),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? Colors.indigo.withOpacity(0.1) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? Colors.indigo : const Color(0xFFE5E7EB),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected ? Colors.indigo : Colors.grey.shade600,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: selected ? Colors.indigo : const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

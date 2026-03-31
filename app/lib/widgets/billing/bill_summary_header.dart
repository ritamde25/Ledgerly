import 'package:flutter/material.dart';

class BillSummaryHeader extends StatelessWidget {
  final bool isEditable;
  final ValueChanged<bool> onEditableChanged;
  final VoidCallback onBackPressed;

  const BillSummaryHeader({
    super.key,
    required this.isEditable,
    required this.onEditableChanged,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1F2937),
              size: 20,
            ),
            onPressed: onBackPressed,
          ),
          const Text(
            'Bill Summary',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            decoration: BoxDecoration(
              color: isEditable
                  ? Colors.indigo.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isEditable
                    ? Colors.indigo.withOpacity(0.2)
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditable ? 'EDITING' : 'LOCKED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isEditable ? Colors.indigo : Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 24,
                  width: 44,
                  child: Switch(
                    value: isEditable,
                    onChanged: onEditableChanged,
                    activeColor: Colors.indigo,
                    activeTrackColor: Colors.indigo.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

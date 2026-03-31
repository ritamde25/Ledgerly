import 'package:flutter/material.dart';

import '../../core/db/models/item.dart';

class BillSummaryItemsCard extends StatelessWidget {
  final List<Item> items;
  final bool isEditable;
  final bool isItemEditingEnabled;
  final VoidCallback onAddItem;
  final VoidCallback onToggleItemEditing;
  final ValueChanged<int> onEditItemPrice;
  final void Function(int index, bool increase) onEditItemQuantity;

  const BillSummaryItemsCard({
    super.key,
    required this.items,
    required this.isEditable,
    required this.isItemEditingEnabled,
    required this.onAddItem,
    required this.onToggleItemEditing,
    required this.onEditItemPrice,
    required this.onEditItemQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
            child: Row(
              children: [
                const Text(
                  'Bill Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                if (isEditable) ...[
                  IconButton(
                    onPressed: onAddItem,
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.indigo,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onToggleItemEditing,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isItemEditingEnabled
                            ? const Color(0xFF1F2937)
                            : Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isItemEditingEnabled
                                ? Icons.check_rounded
                                : Icons.edit_note_rounded,
                            size: 18,
                            color: isItemEditingEnabled
                                ? Colors.white
                                : Colors.indigo,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isItemEditingEnabled ? 'Done' : 'Edit',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isItemEditingEnabled
                                  ? Colors.white
                                  : Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFF3F4F6),
            indent: 24,
            endIndent: 24,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade50,
              indent: 24,
              endIndent: 24,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: isItemEditingEnabled
                            ? () => onEditItemPrice(index)
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '₹${item.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  ' × ${item.quantity}',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isItemEditingEnabled)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: Row(
                          children: [
                            _qtyBtn(
                              Icons.remove_rounded,
                              () => onEditItemQuantity(index, false),
                              Colors.red.shade400,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            _qtyBtn(
                              Icons.add_rounded,
                              () => onEditItemQuantity(index, true),
                              Colors.green.shade400,
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

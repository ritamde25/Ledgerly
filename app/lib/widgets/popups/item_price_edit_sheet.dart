import 'package:flutter/material.dart';

import '../../core/db/models/item.dart';

class ItemPriceEditSheet extends StatefulWidget {
  final Item item;

  const ItemPriceEditSheet({
    super.key,
    required this.item,
  });

  @override
  State<ItemPriceEditSheet> createState() => _ItemPriceEditSheetState();
}

class _ItemPriceEditSheetState extends State<ItemPriceEditSheet> {
  late double tempPrice;

  @override
  void initState() {
    super.initState();
    tempPrice = widget.item.price;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: 12,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const Text(
            'Adjust Price',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.item.name,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _adjustmentBtn(
                Icons.remove_rounded,
                () => setState(() {
                  tempPrice = (tempPrice - 10).clamp(0, 100000);
                }),
                isRed: true,
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    'UNIT PRICE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.indigo.withOpacity(0.5),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${tempPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              _adjustmentBtn(
                Icons.add_rounded,
                () => setState(() {
                  tempPrice += 10;
                }),
                isGreen: true,
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _presetBtn('-₹100', () => tempPrice -= 100),
              _presetBtn('-₹50', () => tempPrice -= 50),
              _presetBtn('+₹50', () => tempPrice += 50),
              _presetBtn('+₹100', () => tempPrice += 100),
            ],
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, tempPrice.clamp(0, 100000));
              },
              style: _buttonStyle(const Color(0xFF1F2937)),
              child: const Text(
                'Update Price',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adjustmentBtn(
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

  Widget _presetBtn(String label, VoidCallback onAction) {
    return InkWell(
      onTap: () => setState(onAction),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF4B5563),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 48,
        height: 5,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
    );
  }
}

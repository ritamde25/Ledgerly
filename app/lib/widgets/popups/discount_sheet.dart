import 'package:flutter/material.dart';

class DiscountSheet extends StatefulWidget {
  final double initialDiscount;
  final double subtotal;

  const DiscountSheet({
    super.key,
    required this.initialDiscount,
    required this.subtotal,
  });

  @override
  State<DiscountSheet> createState() => _DiscountSheetState();
}

class _DiscountSheetState extends State<DiscountSheet> {
  late double tempDiscount;
  late final TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    tempDiscount = widget.initialDiscount;
    _discountController = TextEditingController(
      text: tempDiscount == 0 ? '' : tempDiscount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _setDiscount(double value) {
    final clamped = value.clamp(0, widget.subtotal);
    setState(() {
      tempDiscount = clamped.toDouble();
      _discountController.text = clamped == 0 ? '' : clamped.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const Text(
              'Add Discount',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust absolute cash discount',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _adjustmentBtn(
                  Icons.remove_rounded,
                  () => _setDiscount(tempDiscount - 5),
                  isRed: true,
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Text(
                      'CASH DISCOUNT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.green.withOpacity(0.5),
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '₹${tempDiscount.toStringAsFixed(0)}',
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
                  () => _setDiscount(tempDiscount + 5),
                  isGreen: true,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _quickDiscountBtn('₹10', () {
                  _setDiscount(tempDiscount + 10);
                }),
                _quickDiscountBtn('₹50', () {
                  _setDiscount(tempDiscount + 50);
                }),
                _quickDiscountBtn('₹100', () {
                  _setDiscount(tempDiscount + 100);
                }),
                _quickDiscountBtn('₹500', () {
                  _setDiscount(tempDiscount + 500);
                }),
                _quickDiscountBtn('-₹10', () {
                  _setDiscount(tempDiscount - 10);
                }),
                _quickDiscountBtn('-₹50', () {
                  _setDiscount(tempDiscount - 50);
                }),
                _quickDiscountBtn(
                  'Clear',
                  () {
                    _setDiscount(0);
                  },
                  isDanger: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Or type discount manually',
                labelStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(
                  Icons.edit_rounded,
                  color: Colors.green.shade400,
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
                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                ),
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null) {
                  setState(() {
                    tempDiscount = parsed.clamp(0, widget.subtotal);
                  });
                }
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, tempDiscount.clamp(0, widget.subtotal));
                },
                style: _buttonStyle(const Color(0xFF10B981)),
                child: const Text(
                  'Apply Discount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
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

  Widget _quickDiscountBtn(
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

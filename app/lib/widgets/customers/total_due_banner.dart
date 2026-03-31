import 'package:flutter/material.dart';

class TotalDueBanner extends StatelessWidget {
  final bool isHidden;
  final double totalDue;
  final VoidCallback onNotifyAll;

  const TotalDueBanner({
    super.key,
    required this.isHidden,
    required this.totalDue,
    required this.onNotifyAll,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isHidden ? 0 : 130,
      margin: EdgeInsets.fromLTRB(16, isHidden ? 0 : 8, 16, isHidden ? 0 : 16),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        opacity: isHidden ? 0 : 1,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total to Collect',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${totalDue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: onNotifyAll,
                    icon: const Icon(Icons.sms_rounded, color: Colors.white),
                    tooltip: 'Notify All Overdue',
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

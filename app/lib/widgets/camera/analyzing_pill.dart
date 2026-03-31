import 'package:flutter/material.dart';

class AnalyzingPill extends StatelessWidget {
  final int count;
  final Animation<double> pulse;

  const AnalyzingPill({
    super.key,
    required this.count,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: pulse,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Analyzing $count',
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

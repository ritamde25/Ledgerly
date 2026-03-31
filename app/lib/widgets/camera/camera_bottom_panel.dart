import 'package:flutter/material.dart';

class CameraBottomPanel extends StatelessWidget {
  final String? errorMessage;
  final int capturedCount;
  final bool isCapturing;
  final bool canProceed;
  final bool showWarning;
  final VoidCallback onCapture;
  final VoidCallback? onProceed;

  const CameraBottomPanel({
    super.key,
    required this.errorMessage,
    required this.capturedCount,
    required this.isCapturing,
    required this.canProceed,
    required this.showWarning,
    required this.onCapture,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (errorMessage != null) _ErrorCard(message: errorMessage!),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatPill(label: 'SCANNED', value: '$capturedCount'),
              _CaptureShutter(onTap: onCapture, isCapturing: isCapturing),
              _ProceedActionButton(
                onTap: onProceed,
                isEnabled: canProceed,
                showWarning: showWarning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            canProceed
                ? 'Scan complete. Proceed to checkout.'
                : showWarning
                    ? 'AI is processing detections...'
                    : 'Capture items for smart billing',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureShutter extends StatelessWidget {
  final VoidCallback onTap;
  final bool isCapturing;

  const _CaptureShutter({required this.onTap, required this.isCapturing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCapturing ? null : onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                width: 4,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isCapturing ? 64 : 70,
            height: isCapturing ? 64 : 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: isCapturing
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.add_a_photo_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProceedActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool showWarning;

  const _ProceedActionButton({
    required this.onTap,
    required this.isEnabled,
    required this.showWarning,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: isEnabled ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: isEnabled ? Colors.white : const Color(0xFFCBD5E1),
              size: 28,
            ),
          ),
          if (showWarning)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF991B1B),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

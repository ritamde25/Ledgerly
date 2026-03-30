import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/camera_billing_service.dart';
import 'billing_screen.dart';

class CameraBillingScreen extends StatefulWidget {
  const CameraBillingScreen({super.key});

  @override
  State<CameraBillingScreen> createState() => _CameraBillingScreenState();
}

class _CameraBillingScreenState extends State<CameraBillingScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _cameraController;
  final CameraBillingService _cameraBillingService = CameraBillingService();

  final List<XFile> _capturedImages = [];
  final Map<String, int> _detectedLabelCounts = {};

  bool _isInitializing = true;
  bool _isCapturing = false;
  int _pendingPredictions = 0;
  String? _errorMessage;

  late AnimationController _pulseController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      controller.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No camera available');
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isInitializing = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Unable to start camera';
      });
    }
  }

  Future<void> _captureAndAnalyze() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized || _isCapturing || _isInitializing) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      final capturedImage = await controller.takePicture();

      if (!mounted) return;

      setState(() {
        _capturedImages.add(capturedImage);
        _pendingPredictions += 1;
      });

      unawaited(_predictCapturedImage(capturedImage));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Capture failed';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _predictCapturedImage(XFile image) async {
    try {
      final imageBytes = await image.readAsBytes();
      final labels = await _cameraBillingService.predictLabels(
        imageBytes,
        fileName: image.name,
      );

      if (!mounted) return;

      setState(() {
        for (final label in labels) {
          final normalized = label.trim().toLowerCase();
          _detectedLabelCounts[normalized] = (_detectedLabelCounts[normalized] ?? 0) + 1;
        }
      });
    } catch (error) {
      if (mounted) setState(() => _errorMessage = 'Processing failed');
    } finally {
      if (mounted) {
        setState(() {
          _pendingPredictions = (_pendingPredictions - 1).clamp(0, 9999);
        });
      }
    }
  }

  void _proceedToBilling() {
    if (_capturedImages.isEmpty || _pendingPredictions > 0) return;
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BillingScreen(
          detectedLabelCounts: _detectedLabelCounts,
          sourceImageCount: _capturedImages.length,
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _fadeController.dispose();
    _cameraController?.dispose();
    _cameraBillingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern light slate
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Billing Scan',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'AI Powered Detection',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          if (_pendingPredictions > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _AnalyzingPill(count: _pendingPredictions, pulse: _pulseController),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _buildCameraBox(),
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildCameraBox() {
    final controller = _cameraController;
    final previewAspectRatio =
        (controller != null && controller.value.isInitialized)
            ? _effectivePreviewAspectRatio(controller)
            : 9 / 16;

    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: AspectRatio(
          aspectRatio: previewAspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      color: Colors.black,
                      child: _buildCameraPreview(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController;
    if (_isInitializing || controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _effectivePreviewAspectRatio(controller),
      child: CameraPreview(controller),
    );
  }

  double _effectivePreviewAspectRatio(CameraController controller) {
    final rawAspectRatio = controller.value.aspectRatio;
    if (rawAspectRatio <= 0) {
      return 9 / 16;
    }

    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? 1 / rawAspectRatio
        : rawAspectRatio;
  }

  Widget _buildBottomPanel() {
    final canProceed = _capturedImages.isNotEmpty && _pendingPredictions == 0;
    
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
          if (_errorMessage != null)
             _ErrorCard(message: _errorMessage!),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Count Card - Matches app style
              _StatPill(
                label: 'SCANNED',
                value: '${_capturedImages.length}',
              ),

              // Pro Shutter Button
              _CaptureShutter(
                onTap: _captureAndAnalyze,
                isCapturing: _isCapturing,
              ),

              // Proceed Action
              _ActionButton(
                onTap: canProceed ? _proceedToBilling : null,
                isEnabled: canProceed,
                showWarning: _capturedImages.isNotEmpty && _pendingPredictions > 0,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            canProceed
                ? 'Scan complete. Proceed to checkout.'
                : _pendingPredictions > 0 
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

class _AnalyzingPill extends StatelessWidget {
  final int count;
  final Animation<double> pulse;

  const _AnalyzingPill({required this.count, required this.pulse});

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
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.1), width: 4),
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
                  : const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool showWarning;

  const _ActionButton({this.onTap, required this.isEnabled, required this.showWarning});

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
                      )
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

import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/camera_billing_service.dart';
import '../widgets/camera/analyzing_pill.dart';
import '../widgets/camera/camera_bottom_panel.dart';
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
    Navigator.of(context).pushReplacement(
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
              child: AnalyzingPill(count: _pendingPredictions, pulse: _pulseController),
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
    return CameraBottomPanel(
      errorMessage: _errorMessage,
      capturedCount: _capturedImages.length,
      isCapturing: _isCapturing,
      canProceed: canProceed,
      showWarning: _capturedImages.isNotEmpty && _pendingPredictions > 0,
      onCapture: _captureAndAnalyze,
      onProceed: canProceed ? _proceedToBilling : null,
    );
  }
}

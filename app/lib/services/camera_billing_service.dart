import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../core/config/env_config.dart';

class CameraBillingService {
  CameraBillingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<String>> predictLabels(
    Uint8List imageBytes, {
    String fileName = 'capture.jpg',
  }) async {
    final baseUrl = EnvConfig.instance.flaskApiUrl;
    final endpoint = _buildPredictUri(baseUrl);

    final request = http.MultipartRequest('POST', endpoint)
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
        ),
      );

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_parseBackendError(response.body));
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint("Response from YOLO - $jsonBody");
    final detections = (jsonBody['detections'] as List<dynamic>? ?? const []);

    return detections
        .map((detection) => (detection as Map<String, dynamic>)['label'] as String?)
        .whereType<String>()
        .where((label) => label.trim().isNotEmpty)
        .toList();
  }

  Uri _buildPredictUri(String baseUrl) {
    final normalized = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$normalized/predict');
  }

  String _parseBackendError(String body) {
    try {
      final parsed = jsonDecode(body) as Map<String, dynamic>;
      final error = parsed['error'] as String?;
      if (error != null && error.trim().isNotEmpty) {
        return error;
      }
    } catch (_) {
      // Ignore JSON parse errors and fall back to generic message.
    }

    return 'Prediction failed. Please try again.';
  }

  void dispose() {
    _client.close();
  }
}

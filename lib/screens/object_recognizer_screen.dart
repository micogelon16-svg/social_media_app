import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/recognition_result.dart';
import '../services/recognition_service.dart';
import '../widgets/recognition_result_card.dart';

class ObjectRecognizerScreen extends StatefulWidget {
  const ObjectRecognizerScreen({super.key});

  @override
  State<ObjectRecognizerScreen> createState() =>
      _ObjectRecognizerScreenState();
}

class _ObjectRecognizerScreenState extends State<ObjectRecognizerScreen> {
  CameraController? _cameraController;
  final RecognitionService _recognitionService = RecognitionService();

  bool _isProcessing = false;
  String? _errorMessage;
  File? _capturedImage;
  List<RecognitionResult> _results = [];

  bool get _isCameraInitialised =>
      _cameraController != null && _cameraController!.value.isInitialized;

  @override
  void initState() {
    super.initState();
    _initialiseCamera();
  }

  Future<void> _initialiseCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available on this device.';
        });
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (mounted) {
        setState(() {
          _cameraController = controller;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  Future<void> _captureAndAnalyse() async {
    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _results = [];
    });

    try {
      final XFile captured = await controller.takePicture();
      final Directory directory = await getApplicationDocumentsDirectory();
      final String timestamp =
          DateTime.now().millisecondsSinceEpoch.toString();
      final File savedImage = File(
        '${directory.path}/photo_$timestamp.jpg',
      );
      await File(captured.path).copy(savedImage.path);

      if (mounted) {
        setState(() => _capturedImage = savedImage);
      }

      final List<RecognitionResult> results =
          await _recognitionService.recognizeObjects(savedImage.path);

      if (mounted) {
        setState(() {
          _results = results;
          _isProcessing = false;
        });
      }
    } on RecognitionException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isProcessing = false;
        });
      }
    }
  }

  void _resetForAnotherImage() {
    setState(() {
      _capturedImage = null;
      _results = [];
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Recognizer'),
        actions: [
          if (_capturedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Try another image',
              onPressed: _isProcessing ? null : _resetForAnotherImage,
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null && !_isCameraInitialised) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialised || _cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_capturedImage != null) {
      return _buildResultView();
    }

    return _buildCameraView();
  }

  Widget _buildCameraView() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CameraPreview(_cameraController!),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Point the camera at an object and tap the button.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _captureAndAnalyse,
                icon: _isProcessing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.camera_alt),
                label: Text(
                  _isProcessing
                      ? 'Analysing...'
                      : 'Capture and Recognise',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_capturedImage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _capturedImage!,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
            )
          else if (_results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No objects were recognised. Try a different image.',
                textAlign: TextAlign.center,
              ),
            )
          else ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recognised objects',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ..._results.map(
              (result) => RecognitionResultCard(result: result),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : _resetForAnotherImage,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Another Image'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
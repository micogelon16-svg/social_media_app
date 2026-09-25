import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../models/recognition_result.dart';

class ObjectRecognitionService {
  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );

  Future<List<RecognitionResult>> recognizeObjects(String imagePath) async {
    try {
      final InputImage inputImage =
          InputImage.fromFilePath(imagePath);

      final List<ImageLabel> labels =
          await _labeler.processImage(inputImage);

      return labels
          .map(
            (label) => RecognitionResult(
              label: label.label,
              confidence: label.confidence,
            ),
          )
          .toList();
    } on Exception {
      throw RecognitionException(
        'Could not analyse the image. Please try again.',
      );
    }
  }

  Future<void> dispose() async {
    await _labeler.close();
  }
}

class RecognitionException implements Exception {
  final String message;

  const RecognitionException(this.message);

  @override
  String toString() => message;
}
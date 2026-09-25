class RecognitionResult {
  final String label;
  final double confidence;

  const RecognitionResult({
    required this.label,
    required this.confidence,
  });

  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(1)}%';
}
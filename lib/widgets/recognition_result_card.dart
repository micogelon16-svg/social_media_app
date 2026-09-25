import 'package:flutter/material.dart';
import '../models/recognition_result.dart';

class RecognitionResultCard extends StatelessWidget {
  final RecognitionResult result;

  const RecognitionResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: result.confidence,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(result.confidencePercent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
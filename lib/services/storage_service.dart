import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPostImage({
    required String userId,
    required XFile imageFile,
    required Uint8List imageBytes,
  }) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';

      final Reference ref = _storage.ref().child('posts/$userId/$fileName');

      final TaskSnapshot snapshot = await ref.putData(
        imageBytes,
        SettableMetadata(contentType: imageFile.mimeType ?? 'image/jpeg'),
      );

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(_messageFor(e));
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return;
      throw StorageException(_messageFor(e));
    }
  }

  String _messageFor(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
        return 'You do not have permission to upload that file.';
      case 'canceled':
        return 'The upload was cancelled.';
      case 'object-not-found':
        return 'That file no longer exists.';
      case 'quota-exceeded':
        return 'Storage quota exceeded. Please try again later.';
      case 'retry-limit-exceeded':
        return 'The upload took too long. Please try again.';
      default:
        return 'Upload failed. Please try again.';
    }
  }
}

class StorageException implements Exception {
  final String message;

  const StorageException(this.message);

  @override
  String toString() => message;
}
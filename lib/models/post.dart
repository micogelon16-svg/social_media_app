import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String authorEmail;
  final String text;
  final String? imageUrl;
  final DateTime? createdAt;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorEmail,
    required this.text,
    this.imageUrl,
    this.createdAt,
  });

  /// Creates a [Post] instance from a Firestore document snapshot.
  factory Post.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

    return Post(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      authorEmail: data['authorEmail'] as String? ?? '',
      text: data['text'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Converts the post instance to a map for writing to Firestore.
  ///
  /// Use [isNew] = true when creating a document so Firestore applies
  /// a server-side timestamp automatically.
  Map<String, dynamic> toFirestore({bool isNew = false}) {
    return {
      'authorId': authorId,
      'authorEmail': authorEmail,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': isNew
          ? FieldValue.serverTimestamp()
          : (createdAt != null ? Timestamp.fromDate(createdAt!) : null),
    };
  }

  /// Returns a copy of this [Post] with the given fields replaced with new values.
  Post copyWith({
    String? id,
    String? authorId,
    String? authorEmail,
    String? text,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorEmail: authorEmail ?? this.authorEmail,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

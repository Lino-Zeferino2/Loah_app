import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a daily reflection ("Reflexão do Dia") stored in Firestore.
///
/// Each reflection has a [text] (the quote/message), an [imageUrl] for
/// the scenic background photo, a flag [active] to indicate which one
/// should be shown on the Dashboard, and a [createdAt] timestamp.
class ReflectionModel {
  final String id;
  final String text;
  final String imageUrl;
  final bool active;
  final DateTime? createdAt;

  const ReflectionModel({
    required this.id,
    required this.text,
    required this.imageUrl,
    this.active = false,
    this.createdAt,
  });

  /// Build a model from a Firestore document snapshot.
  factory ReflectionModel.fromMap(String id, Map<String, dynamic> data) {
    return ReflectionModel(
      id: id,
      text: data['text'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      active: data['active'] as bool? ?? false,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  /// Serialise to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageUrl': imageUrl,
      'active': active,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Returns a copy with the given fields replaced.
  ReflectionModel copyWith({
    String? text,
    String? imageUrl,
    bool? active,
    DateTime? createdAt,
  }) {
    return ReflectionModel(
      id: id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a daily reflection ("Reflexão do Dia") stored in Firestore.
///
/// Each reflection has a [text] (the quote/message in Portuguese), an
/// optional [textEn] for the English version, an [imageUrl] for the scenic
/// background photo, a flag [active] and a [createdAt] timestamp.
class ReflectionModel {
  final String id;
  final String text;
  final String? textEn;
  final String imageUrl;
  final bool active;
  final DateTime? createdAt;

  const ReflectionModel({
    required this.id,
    required this.text,
    this.textEn,
    required this.imageUrl,
    this.active = false,
    this.createdAt,
  });

  /// Build a model from a Firestore document snapshot.
  factory ReflectionModel.fromMap(String id, Map<String, dynamic> data) {
    return ReflectionModel(
      id: id,
      text: data['text'] as String? ?? '',
      textEn: data['textEn'] as String?,
      imageUrl: data['imageUrl'] as String? ?? '',
      active: data['active'] as bool? ?? false,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  /// Serialise to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      if (textEn != null) 'textEn': textEn,
      'imageUrl': imageUrl,
      'active': active,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Returns a copy with the given fields replaced.
  ReflectionModel copyWith({
    String? text,
    String? textEn,
    String? imageUrl,
    bool? active,
    DateTime? createdAt,
  }) {
    return ReflectionModel(
      id: id,
      text: text ?? this.text,
      textEn: textEn ?? this.textEn,
      imageUrl: imageUrl ?? this.imageUrl,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns the appropriate text based on the given language code.
  /// Falls back to [text] (Portuguese) if [textEn] is null.
  String localizedText(String languageCode) {
    if (languageCode == 'en' && textEn != null && textEn!.isNotEmpty) {
      return textEn!;
    }
    return text;
  }
}


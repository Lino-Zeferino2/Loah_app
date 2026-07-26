import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:loah_app/models/reflection_model.dart';

/// Service to manage daily reflections ("Reflexões do Dia") in Firestore
/// and their associated images in Firebase Storage.
class ReflectionService {
  static final ReflectionService _instance = ReflectionService._internal();
  factory ReflectionService() => _instance;
  ReflectionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _reflections =>
      _firestore.collection('reflections');

  // ────────────────────────────────────────────────────────────────
  //  CRUD
  // ────────────────────────────────────────────────────────────────

  /// Stream of all reflections, newest first.
  Stream<QuerySnapshot> getReflectionsStream() {
    return _reflections.orderBy('createdAt', descending: true).snapshots();
  }

  /// Fetch the currently active reflection (for the dashboard).
  Future<ReflectionModel?> getActiveReflection() async {
    final snap = await _reflections
        .where('active', isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return ReflectionModel.fromMap(
      doc.id,
      doc.data() as Map<String, dynamic>,
    );
  }

  /// Add a new reflection to Firestore.
  Future<void> addReflection(ReflectionModel reflection) async {
    await _reflections.add(reflection.toMap());
  }

  /// Update an existing reflection.
  Future<void> updateReflection(ReflectionModel reflection) async {
    await _reflections.doc(reflection.id).update(reflection.toMap());
  }

  /// Deactivate all reflections (set active = false on all).
  Future<void> _deactivateAll() async {
    final snap = await _reflections.where('active', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'active': false});
    }
    await batch.commit();
  }

  /// Set a specific reflection as the active one, deactivating others.
  Future<void> setActiveReflection(String reflectionId) async {
    await _deactivateAll();
    await _reflections.doc(reflectionId).update({'active': true});
  }

  /// Delete a reflection document and its image from Storage.
  Future<void> deleteReflection(String reflectionId, String? imageUrl) async {
    // Delete the image file from Storage if present
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      } catch (_) {
        // Image may have been deleted already – ignore.
      }
    }
    await _reflections.doc(reflectionId).delete();
  }

  // ────────────────────────────────────────────────────────────────
  //  Image Upload
  // ────────────────────────────────────────────────────────────────

  /// Upload an image file to Firebase Storage and return the download URL.
  ///
  /// The file is stored under `reflections/{userId}/{timestamp}.jpg`.
  /// Returns `null` if [file] is `null`.
  Future<String?> uploadImage(File? file, {required String userId}) async {
    if (file == null) return null;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref('reflections/$userId/$timestamp.jpg');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}


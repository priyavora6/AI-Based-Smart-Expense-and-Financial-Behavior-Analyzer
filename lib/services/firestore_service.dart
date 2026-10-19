import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

/// Generic Firestore CRUD operations.
/// Used by other services when they need basic read/write.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseService.firestore;

  // ── Create ────────────────────────────────────

  Future<String> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    final docRef = await _db.collection(collection).add(data);
    return docRef.id;
  }

  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    await _db
        .collection(collection)
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  // ── Read ──────────────────────────────────────

  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    return await _db.collection(collection).doc(docId).get();
  }

  Future<QuerySnapshot> getCollection({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query query = _db.collection(collection);
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return await query.get();
  }

  // ── Update ────────────────────────────────────

  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection(collection).doc(docId).update(data);
  }

  // ── Delete ────────────────────────────────────

  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await _db.collection(collection).doc(docId).delete();
  }

  // ── Query ─────────────────────────────────────

  Future<QuerySnapshot> queryDocuments({
    required String collection,
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query query =
    _db.collection(collection).where(field, isEqualTo: value);
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return await query.get();
  }

  // ── Stream (Real-time) ────────────────────────

  Stream<QuerySnapshot> streamDocuments({
    required String collection,
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
  }) {
    Query query =
    _db.collection(collection).where(field, isEqualTo: value);
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query.snapshots();
  }
}
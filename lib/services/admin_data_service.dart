import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_constants.dart';
import 'firebase_service.dart';

class AdminDataService {
  final FirebaseFirestore _db = FirebaseService.firestore;

  Future<void> savePrediction({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final userId = FirebaseService.currentUserId;
    if (userId.isEmpty) return;
    await _db.collection(AppConstants.colPredictions).add({
      'userId': userId,
      'type': type,
      'data': data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveApiLog({
    required String endpoint,
    required String method,
    required int statusCode,
    required int durationMs,
    String? error,
  }) async {
    final userId = FirebaseService.currentUserId;
    if (userId.isEmpty) return;
    await _db.collection(AppConstants.colApiLogs).add({
      'userId': userId,
      'endpoint': endpoint,
      'method': method,
      'statusCode': statusCode,
      'durationMs': durationMs,
      'success': statusCode >= 200 && statusCode < 300,
      'error': error,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveAuditLog({
    required String action,
    required String resource,
    Map<String, dynamic>? details,
  }) async {
    final userId = FirebaseService.currentUserId;
    if (userId.isEmpty) return;
    await _db.collection(AppConstants.colAuditLogs).add({
      'userId': userId,
      'action': action,
      'resource': resource,
      'details': details ?? <String, dynamic>{},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

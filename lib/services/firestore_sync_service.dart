import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:past_questions/services/local_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Syncs Firestore `questions` collection into local SQLite.
///
/// Source of truth: Cloud Firestore
/// Local search: SQLite
class FirestoreSyncService {
  FirestoreSyncService({
    FirebaseFirestore? firestore,
    LocalDatabase? local,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _local = local ?? LocalDatabase.instance;

  final FirebaseFirestore _firestore;
  final LocalDatabase _local;

  static const String _prefsLastSync = 'last_sync_at_ms';
  static const String _questionsCollection = 'questions';

  CollectionReference<Map<String, dynamic>> get _questionsRef =>
      _firestore.collection(_questionsCollection);

  /// Full sync:
  /// 1) Pull every document from Firestore `questions`
  /// 2) Clear local SQLite
  /// 3) Upsert all rows into SQLite
  /// 4) Save latest `updatedAt` as milliseconds in SharedPreferences
  Future<SyncOutcome> fullSync() async {
    try {
      debugPrint('[FirestoreSyncService] fullSync start');
      final snapshot = await _questionsRef.get();
      await _local.clearAll();

      if (snapshot.docs.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_prefsLastSync, DateTime.now().millisecondsSinceEpoch);
        return const SyncOutcome.ok(isFull: true, count: 0);
      }

      final rows = snapshot.docs.map(_docToLocalRow).toList(growable: false);
      await _local.insertOrUpdateQuestions(rows);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _prefsLastSync,
        _maxUpdatedAtMs(rows) ?? DateTime.now().millisecondsSinceEpoch,
      );
      return SyncOutcome.ok(isFull: true, count: rows.length);
    } on FirebaseException catch (e, st) {
      debugPrint('[FirestoreSyncService] fullSync firebase error: $e\n$st');
      rethrow;
    } catch (e, st) {
      debugPrint('[FirestoreSyncService] fullSync error: $e\n$st');
      rethrow;
    }
  }

  /// Incremental sync using Firestore timestamp comparison:
  /// - query where('updatedAt', isGreaterThan: lastSyncDate)
  /// - orderBy('updatedAt')
  ///
  /// `last_sync_at_ms` is stored as milliseconds in SharedPreferences.
  Future<SyncOutcome> incrementalSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_prefsLastSync) ?? 0;
      final lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastMs);

      final snapshot = await _questionsRef
          .where('updatedAt', isGreaterThan: Timestamp.fromDate(lastSyncDate))
          .orderBy('updatedAt')
          .get();

      if (snapshot.docs.isEmpty) {
        return const SyncOutcome.ok(isFull: false, count: 0);
      }

      final rows = snapshot.docs.map(_docToLocalRow).toList(growable: false);
      await _local.insertOrUpdateQuestions(rows);

      final maxMs = _maxUpdatedAtMs(rows);
      if (maxMs != null && maxMs > lastMs) {
        await prefs.setInt(_prefsLastSync, maxMs);
      }
      return SyncOutcome.ok(isFull: false, count: rows.length);
    } on FirebaseException catch (e, st) {
      debugPrint('[FirestoreSyncService] incrementalSync firebase error: $e\n$st');
      rethrow;
    } catch (e, st) {
      debugPrint('[FirestoreSyncService] incrementalSync error: $e\n$st');
      rethrow;
    }
  }

  Map<String, dynamic> _docToLocalRow(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final updatedAt = data['updatedAt'];
    final updatedAtMs = updatedAt is Timestamp
        ? updatedAt.millisecondsSinceEpoch
        : (updatedAt is DateTime ? updatedAt.millisecondsSinceEpoch : _asInt(updatedAt));

    return <String, dynamic>{
      'id': doc.id,
      'title': data['title']?.toString(),
      'courseCode': data['courseCode']?.toString(),
      'courseTitle': data['courseTitle']?.toString(),
      'year': _asInt(data['year']),
      'semester': _asInt(data['semester']),
      'department': data['department']?.toString(),
      'faculty': data['faculty']?.toString(),
      'r2Path': data['r2Path']?.toString(),
      'downloads': _asInt(data['downloads']),
      'updatedAt': updatedAtMs ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  int? _maxUpdatedAtMs(List<Map<String, dynamic>> rows) {
    int? max;
    for (final row in rows) {
      final value = _asInt(row['updatedAt']);
      if (value == null) continue;
      if (max == null || value > max) {
        max = value;
      }
    }
    return max;
  }
}

class SyncOutcome {
  const SyncOutcome._({
    required this.success,
    this.message,
    required this.isFull,
    required this.count,
  });

  const SyncOutcome.ok({required this.isFull, this.count = 0})
      : success = true,
        message = null;

  factory SyncOutcome.failure(String message) {
    return SyncOutcome._(
      success: false,
      message: message,
      isFull: false,
      count: 0,
    );
  }

  final bool success;
  final String? message;
  final bool isFull;
  final int count;
}

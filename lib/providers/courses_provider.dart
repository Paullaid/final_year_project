import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CoursesProvider extends ChangeNotifier {
  final _col = FirebaseFirestore.instance.collection('courses');
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  DocumentSnapshot<Map<String, dynamic>>? _last;
  bool _hasMore = true;
  bool _loading = false;
  String _search = '';

  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String get search => _search;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get items {
    if (_search.trim().isEmpty) return List.unmodifiable(_docs);
    final q = _search.trim().toLowerCase();
    return _docs.where((d) {
      final m = d.data();
      return (m['courseCode']?.toString().toLowerCase().contains(q) ?? false) ||
          (m['courseTitle']?.toString().toLowerCase().contains(q) ?? false);
    }).toList(growable: false);
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> refresh() async {
    _docs.clear();
    _last = null;
    _hasMore = true;
    await fetchNext();
  }

  Future<void> fetchNext({int limit = 20}) async {
    if (_loading || !_hasMore) return;
    _loading = true;
    notifyListeners();
    try {
      Query<Map<String, dynamic>> q = _col.orderBy('courseCode').limit(limit);
      if (_last != null) q = q.startAfterDocument(_last!);
      final snap = await q.get();
      if (snap.docs.isEmpty) {
        _hasMore = false;
      } else {
        _docs.addAll(snap.docs);
        _last = snap.docs.last;
        if (snap.docs.length < limit) _hasMore = false;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addCourse(Map<String, dynamic> data) async {
    final now = FieldValue.serverTimestamp();
    await _col.add({...data, 'createdAt': now, 'updatedAt': now});
    await refresh();
  }

  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update({...data, 'updatedAt': FieldValue.serverTimestamp()});
    await refresh();
  }

  Future<void> deleteCourse(String id, {bool cascadePastQuestions = true}) async {
    final batch = FirebaseFirestore.instance.batch();
    batch.delete(_col.doc(id));
    if (cascadePastQuestions) {
      final pq = await FirebaseFirestore.instance
          .collection('pastQuestions')
          .where('courseId', isEqualTo: id)
          .get();
      for (final d in pq.docs) {
        batch.delete(d.reference);
      }
    }
    await batch.commit();
    await refresh();
  }

  Future<void> bulkImportFromString(String payload) async {
    final trimmed = payload.trim();
    if (trimmed.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
      final parsed = jsonDecode(trimmed);
      final list = parsed is List ? parsed : (parsed['courses'] as List<dynamic>? ?? const []);
      for (final item in list) {
        final map = Map<String, dynamic>.from(item as Map);
        final ref = _col.doc();
        final now = FieldValue.serverTimestamp();
        batch.set(ref, {...map, 'createdAt': now, 'updatedAt': now});
      }
    } else {
      final rows = trimmed
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => e.split(',').map((v) => v.trim()).toList())
          .toList();
      if (rows.length < 2) return;
      final headers = rows.first;
      for (final row in rows.skip(1)) {
        final map = <String, dynamic>{};
        for (var i = 0; i < headers.length && i < row.length; i++) {
          map[headers[i]] = row[i];
        }
        final ref = _col.doc();
        final now = FieldValue.serverTimestamp();
        batch.set(ref, {...map, 'createdAt': now, 'updatedAt': now});
      }
    }
    await batch.commit();
    await refresh();
  }
}

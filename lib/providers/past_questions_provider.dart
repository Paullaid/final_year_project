import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'upload_provider.dart';

class PastQuestionsProvider extends ChangeNotifier {
  final _col = FirebaseFirestore.instance.collection('pastQuestions');
  final _userQuestionsMirror = FirebaseFirestore.instance.collection('questions');

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  DocumentSnapshot<Map<String, dynamic>>? _last;
  bool _hasMore = true;
  bool _loading = false;
  String _search = '';

  bool get loading => _loading;
  bool get hasMore => _hasMore;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get items {
    if (_search.trim().isEmpty) return List.unmodifiable(_docs);
    final q = _search.trim().toLowerCase();
    return _docs.where((d) {
      final m = d.data();
      return (m['courseCode']?.toString().toLowerCase().contains(q) ?? false) ||
          (m['title']?.toString().toLowerCase().contains(q) ?? false) ||
          (m['year']?.toString().toLowerCase().contains(q) ?? false);
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
      Query<Map<String, dynamic>> q = _col.orderBy('uploadedAt', descending: true).limit(limit);
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

  Future<void> addPastQuestion({
    required Map<String, dynamic> course,
    required int year,
    required int semester,
    required String title,
    required String r2Path,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final data = <String, dynamic>{
      'courseId': course['id'],
      'courseCode': course['courseCode'],
      'year': year,
      'semester': semester,
      'title': title,
      'r2Path': r2Path,
      'downloads': 0,
      'uploadedBy': uid,
      'uploadedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final doc = _col.doc();
    final batch = FirebaseFirestore.instance.batch();
    batch.set(doc, data);
    batch.set(_userQuestionsMirror.doc(doc.id), {
      'title': title,
      'courseCode': course['courseCode'],
      'courseTitle': course['courseTitle'],
      'year': year,
      'semester': semester,
      'department': course['departmentName'],
      'faculty': course['facultyName'],
      'r2Path': r2Path,
      'downloads': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    await refresh();
  }

  Future<void> updatePastQuestion({
    required String id,
    required int year,
    required int semester,
    required String title,
    String? r2Path,
  }) async {
    final update = <String, dynamic>{
      'year': year,
      'semester': semester,
      'title': title,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (r2Path != null) update['r2Path'] = r2Path;
    final batch = FirebaseFirestore.instance.batch();
    batch.update(_col.doc(id), update);
    batch.update(_userQuestionsMirror.doc(id), update);
    await batch.commit();
    await refresh();
  }

  Future<void> deletePastQuestion({
    required String id,
    required String r2Path,
    required UploadProvider uploadProvider,
  }) async {
    await uploadProvider.deletePdf(r2Path);
    final batch = FirebaseFirestore.instance.batch();
    batch.delete(_col.doc(id));
    batch.delete(_userQuestionsMirror.doc(id));
    await batch.commit();
    await refresh();
  }
}

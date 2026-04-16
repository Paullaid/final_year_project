import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DepartmentsProvider extends ChangeNotifier {
  final _departments = FirebaseFirestore.instance.collection('departments');
  final _faculties = FirebaseFirestore.instance.collection('faculties');

  List<QueryDocumentSnapshot<Map<String, dynamic>>> departments = const [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> faculties = const [];
  bool loading = false;

  Future<void> refresh() async {
    loading = true;
    notifyListeners();
    try {
      final dep = await _departments.orderBy('name').get();
      final fac = await _faculties.orderBy('name').get();
      departments = dep.docs;
      faculties = fac.docs;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addDepartment(String name) async {
    await _departments.add({
      'name': name.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await refresh();
  }

  Future<void> addFaculty(String name) async {
    await _faculties.add({
      'name': name.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await refresh();
  }

  Future<void> updateDepartment(String id, String name) async {
    await _departments.doc(id).update({
      'name': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await refresh();
  }

  Future<void> updateFaculty(String id, String name) async {
    await _faculties.doc(id).update({
      'name': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await refresh();
  }

  Future<void> deleteDepartment(String id) async {
    await _departments.doc(id).delete();
    await refresh();
  }

  Future<void> deleteFaculty(String id) async {
    await _faculties.doc(id).delete();
    await refresh();
  }
}

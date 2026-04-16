import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> create({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.doc(path).set(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> read({
    required String path,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.doc(path).get();
    return snapshot;
  }

  Future<void> update({
    required String path,
    required Map<String, Object?> data,
  }) async {
    await _firestore.doc(path).update(data);
  }

  Future<void> delete({
    required String path,
  }) async {
    await _firestore.doc(path).delete();
  }
}

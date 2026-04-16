import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:past_questions/firebase_options.dart';

/// One-time migration utility:
/// RTDB /questions -> Firestore /questions (same doc IDs).
///
/// Run with:
/// 1) flutter pub add firebase_database
/// 2) dart run tool/migrate_rtdb_to_firestore.dart
/// 3) flutter pub remove firebase_database
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final rtdbRef = FirebaseDatabase.instance.ref('questions');
  final rtdbSnapshot = await rtdbRef.get();
  final firestore = FirebaseFirestore.instance;

  if (!rtdbSnapshot.exists || rtdbSnapshot.value == null) {
    debugPrint('No data found at RTDB /questions.');
    return;
  }

  final data = Map<dynamic, dynamic>.from(rtdbSnapshot.value as Map);
  var migrated = 0;
  WriteBatch batch = firestore.batch();
  var ops = 0;

  for (final entry in data.entries) {
    final docId = entry.key.toString();
    final docData = Map<String, dynamic>.from(entry.value as Map);

    if (docData['updatedAt'] is int) {
      docData['updatedAt'] = Timestamp.fromMillisecondsSinceEpoch(docData['updatedAt'] as int);
    } else if (docData['updatedAt'] == null) {
      docData['updatedAt'] = FieldValue.serverTimestamp();
    }

    final docRef = firestore.collection('questions').doc(docId);
    batch.set(docRef, docData, SetOptions(merge: true));
    ops++;
    migrated++;

    if (ops >= 450) {
      await batch.commit();
      batch = firestore.batch();
      ops = 0;
    }
  }

  if (ops > 0) {
    await batch.commit();
  }

  debugPrint('Migrated $migrated documents.');
}

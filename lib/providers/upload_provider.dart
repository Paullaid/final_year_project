import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:past_questions/services/app_config_service.dart';

class UploadProvider extends ChangeNotifier {
  bool uploading = false;
  double? progress;

  String get _workerBase {
    final base = AppConfigService.instance.workerUrl;
    if (base == null || base.isEmpty) {
      throw Exception('R2_WORKER_URL is not configured.');
    }
    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }

  Future<String> uploadPdf({
    required PlatformFile file,
    required String courseCode,
    required int year,
    required int semester,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) throw Exception('You must be signed in as admin.');
    final bytes = file.bytes;
    if (bytes == null) throw Exception('Could not read selected file bytes.');
    uploading = true;
    progress = 0.1;
    notifyListeners();
    try {
      final uri = Uri.parse('$_workerBase/admin/upload').replace(
        queryParameters: {
          'courseCode': courseCode,
          'year': '$year',
          'semester': '$semester',
          'filename': file.name,
        },
      );
      final req = http.Request('PUT', uri)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/pdf',
        })
        ..bodyBytes = bytes;
      final res = await req.send();
      progress = 0.85;
      notifyListeners();
      final body = await res.stream.bytesToString();
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Upload failed (${res.statusCode}): $body');
      }
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final r2Path = decoded['r2Path']?.toString();
      if (r2Path == null || r2Path.isEmpty) {
        throw Exception('Worker did not return r2Path');
      }
      progress = 1;
      return r2Path;
    } finally {
      uploading = false;
      progress = null;
      notifyListeners();
    }
  }

  Future<void> deletePdf(String r2Path) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) throw Exception('You must be signed in as admin.');
    final uri = Uri.parse('$_workerBase/admin/delete');
    final res = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'r2Path': r2Path}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Delete failed (${res.statusCode}): ${res.body}');
    }
  }
}

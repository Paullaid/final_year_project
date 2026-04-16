import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Fetches short-lived pre-signed URLs from your Cloudflare Worker (never uses R2 keys in-app).
class R2ServiceException implements Exception {
  R2ServiceException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class R2Service {
  R2Service({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  static const String _envWorkerUrl = 'R2_WORKER_URL';

  /// Base URL from [.env] (local dev) or set via [overrideWorkerUrl] for tests / Remote Config wiring.
  String? resolveWorkerBaseUrl({String? overrideWorkerUrl}) {
    final o = overrideWorkerUrl?.trim();
    if (o != null && o.isNotEmpty) return o.endsWith('/') ? o.substring(0, o.length - 1) : o;
    final fromEnv = dotenv.env[_envWorkerUrl]?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv.endsWith('/') ? fromEnv.substring(0, fromEnv.length - 1) : fromEnv;
    }
    return null;
  }

  /// GET `$workerBase/$r2Path` → parses `{ "url": "..." }`.
  Future<String> getPresignedUrl(
    String r2Path, {
    String? overrideWorkerUrl,
  }) async {
    final base = resolveWorkerBaseUrl(overrideWorkerUrl: overrideWorkerUrl);
    if (base == null || base.isEmpty) {
      throw R2ServiceException(
        'Worker URL is not configured. Set $_envWorkerUrl in .env (dev) or Remote Config (prod).',
      );
    }
    final path = r2Path.trim().replaceFirst(RegExp(r'^/+'), '');
    if (path.isEmpty) {
      throw R2ServiceException('Missing PDF path (r2Path).');
    }
    final uri = Uri.parse('$base/$path');
    http.Response res;
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      res = await _client.get(
        uri,
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 45));
    } catch (e) {
      throw R2ServiceException('Network error while contacting worker: $e');
    }
    if (res.statusCode == 404) {
      throw R2ServiceException('PDF not found (404).', statusCode: 404);
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw R2ServiceException(
        'Worker error (${res.statusCode}): ${res.body.isNotEmpty ? res.body : "no body"}',
        statusCode: res.statusCode,
      );
    }
    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected JSON object');
      }
      json = decoded;
    } catch (e) {
      throw R2ServiceException('Invalid JSON from worker: $e');
    }
    final url = json['url']?.toString();
    if (url == null || url.isEmpty) {
      throw R2ServiceException('Worker response missing "url" field.');
    }
    final out = Uri.tryParse(url);
    if (out == null || !out.hasScheme) {
      throw R2ServiceException('Invalid presigned URL returned by worker.');
    }
    return url;
  }
}

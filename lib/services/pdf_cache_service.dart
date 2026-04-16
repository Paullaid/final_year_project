import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Caches downloaded PDFs under app documents to avoid re-downloading the same [r2Path].
class PdfCacheService {
  PdfCacheService({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  Future<Directory> _cacheDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'pdf_cache'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _fileNameForPath(String r2Path) {
    final safe = r2Path.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final trimmed = safe.length > 180 ? safe.substring(safe.length - 180) : safe;
    return '${trimmed.hashCode.abs()}_$trimmed.pdf';
  }

  /// Returns a local file, downloading from [presignedUrl] if missing.
  Future<File> loadOrDownload({
    required String r2Path,
    required String presignedUrl,
    void Function(double? progress)? onProgress,
  }) async {
    final dir = await _cacheDir();
    final file = File(p.join(dir.path, _fileNameForPath(r2Path)));
    if (await file.exists() && await file.length() > 0) {
      debugPrint('[PdfCacheService] cache hit: ${file.path}');
      return file;
    }

    debugPrint('[PdfCacheService] downloading → ${file.path}');
    final uri = Uri.parse(presignedUrl);
    final request = http.Request('GET', uri);
    final streamed = await _client.send(request);
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      final errBytes = await streamed.stream.toBytes();
      final body = utf8.decode(errBytes, allowMalformed: true);
      throw PdfCacheException(
        'Download failed (${streamed.statusCode}): ${body.isNotEmpty ? body : "empty body"}',
      );
    }
    final total = streamed.contentLength;
    final sink = file.openWrite();
    var received = 0;
    try {
      await for (final chunk in streamed.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total != null && total > 0) {
          onProgress?.call(received / total);
        } else {
          onProgress?.call(null);
        }
      }
    } finally {
      await sink.close();
    }
    onProgress?.call(1);
    return file;
  }
}

class PdfCacheException implements Exception {
  PdfCacheException(this.message);
  final String message;
  @override
  String toString() => message;
}

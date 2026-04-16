import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:past_questions/services/app_config_service.dart';
import 'package:past_questions/services/firestore_sync_service.dart';
import 'package:past_questions/services/local_database.dart';
import 'package:past_questions/services/pdf_cache_service.dart';
import 'package:past_questions/services/r2_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Offline-first search backed by SQLite; PDFs open via Worker pre-signed URLs.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final LocalDatabase _db = LocalDatabase.instance;
  final R2Service _r2 = R2Service();
  final PdfCacheService _cache = PdfCacheService();

  List<Map<String, dynamic>> _results = const [];
  bool _loadingList = true;
  String? _openingId;
  double? _downloadProgress;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _reloadFromLocal(showSpinner: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reloadFromLocal({bool showSpinner = false}) async {
    if (showSpinner) setState(() => _loadingList = true);
    try {
      final rows = await _db.searchQuestions(_searchController.text);
      if (!mounted) return;
      setState(() => _results = rows);
    } finally {
      if (mounted && showSpinner) setState(() => _loadingList = false);
    }
  }

  Future<void> _onRefresh() async {
    try {
      final outcome = await FirestoreSyncService().incrementalSync();
      if (!mounted) return;
      if (!outcome.success) {
        final msg = outcome.message ?? 'Sync failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      } else {
        await _reloadFromLocal();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openPdf(Map<String, dynamic> row) async {
    final id = row['id']?.toString() ?? '';
    final r2Path = row['r2Path']?.toString();
    if (r2Path == null || r2Path.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This question has no PDF path yet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _openingId = id;
      _downloadProgress = 0;
    });

    try {
      final presigned = await _r2.getPresignedUrl(
        r2Path,
        overrideWorkerUrl: AppConfigService.instance.workerUrl,
      );
      final file = await _cache.loadOrDownload(
        r2Path: r2Path,
        presignedUrl: presigned,
        onProgress: (p) {
          if (!mounted) return;
          setState(() => _downloadProgress = p);
        },
      );
      if (!mounted) return;
      final title =
          row['title']?.toString() ?? row['courseCode']?.toString() ?? 'Past question';
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => _PdfViewerScreen(
            title: title,
            file: file,
            presignedUrl: presigned,
          ),
        ),
      );
    } on R2ServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PdfCacheException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open PDF: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingId = null;
          _downloadProgress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Offline cache — pull down to sync from Firebase',
                        style: GoogleFonts.lato(
                          fontSize: 13.5,
                          color: scheme.onSurface.withOpacity(isDark ? 0.72 : 0.62),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => _reloadFromLocal(),
                        decoration: InputDecoration(
                          hintText: 'Course code, title, or course name…',
                          prefixIcon: Icon(Icons.search, color: scheme.primary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _reloadFromLocal();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: _loadingList
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(child: CircularProgressIndicator()),
                            ],
                          )
                        : _results.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(top: 80),
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 72,
                                    color: scheme.onSurface.withOpacity(0.28),
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Text(
                                      'No matches (try syncing or a different query)',
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: scheme.onSurface.withOpacity(0.62),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                itemCount: _results.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final q = _results[index];
                                  final courseCode = q['courseCode']?.toString() ?? '—';
                                  final title = q['title']?.toString() ?? '';
                                  final year = q['year']?.toString() ?? '—';
                                  final dept = q['department']?.toString() ?? '—';
                                  final id = q['id']?.toString() ?? '';
                                  final busy = _openingId == id;

                                  return Material(
                                    color: scheme.surfaceContainerHighest.withOpacity(
                                      isDark ? 0.35 : 0.65,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: busy ? null : () => _openPdf(q),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: scheme.primary.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.picture_as_pdf_outlined,
                                                color: scheme.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    courseCode,
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    title.isEmpty ? 'Untitled' : title,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.lato(
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 6,
                                                    children: [
                                                      _MetaChip(icon: Icons.calendar_today, label: year),
                                                      _MetaChip(icon: Icons.apartment, label: dept),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (busy)
                                              const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_openingId != null)
          Positioned.fill(
            child: Material(
              color: Colors.black.withOpacity(0.35),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 14),
                          Text(
                            'Preparing PDF…',
                            style: GoogleFonts.lato(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          if (_downloadProgress != null)
                            LinearProgressIndicator(value: _downloadProgress)
                          else
                            const LinearProgressIndicator(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(isDark ? 0.22 : 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _PdfViewerScreen extends StatelessWidget {
  const _PdfViewerScreen({
    required this.title,
    required this.file,
    required this.presignedUrl,
  });

  final String title;
  final File file;
  final String presignedUrl;

  Future<void> _openExternal(BuildContext context) async {
    final uri = Uri.parse(presignedUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open an external viewer.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Open externally',
            onPressed: () => _openExternal(context),
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: SfPdfViewer.file(file),
    );
  }
}

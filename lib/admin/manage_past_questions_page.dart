import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:past_questions/providers/courses_provider.dart';
import 'package:past_questions/providers/past_questions_provider.dart';
import 'package:past_questions/providers/upload_provider.dart';
import 'package:provider/provider.dart';

class ManagePastQuestionsPage extends StatefulWidget {
  const ManagePastQuestionsPage({super.key});

  @override
  State<ManagePastQuestionsPage> createState() => _ManagePastQuestionsPageState();
}

class _ManagePastQuestionsPageState extends State<ManagePastQuestionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PastQuestionsProvider>().refresh();
      context.read<CoursesProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PastQuestionsProvider>();
    final up = context.watch<UploadProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Past Questions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPastQuestionForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Past Question'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by code/title/year',
                border: OutlineInputBorder(),
              ),
              onChanged: p.setSearch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _bulkUpload(context),
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Bulk Upload PDFs'),
                ),
              ],
            ),
          ),
          if (up.uploading && up.progress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: LinearProgressIndicator(value: up.progress),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: p.refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: p.items.length + (p.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= p.items.length) {
                    return Center(
                      child: TextButton(
                        onPressed: p.loading ? null : () => p.fetchNext(),
                        child: Text(p.loading ? 'Loading...' : 'Load more'),
                      ),
                    );
                  }
                  final doc = p.items[index];
                  final m = doc.data();
                  return Card(
                    child: ListTile(
                      title: Text(
                        '${m['courseCode'] ?? ''} - ${m['title'] ?? ''}',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Year ${m['year'] ?? ''} | Semester ${m['semester'] ?? ''} | '
                        'Downloads ${m['downloads'] ?? 0}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'edit') {
                            await _showPastQuestionForm(context, docId: doc.id, initial: m);
                          } else {
                            final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete past question?'),
                                    content: const Text('This deletes metadata and the PDF in R2.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (!ok) return;
                            try {
                              await p.deletePastQuestion(
                                id: doc.id,
                                r2Path: m['r2Path']?.toString() ?? '',
                                uploadProvider: context.read<UploadProvider>(),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Past question deleted')),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Delete failed: $e')),
                              );
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit / Replace PDF')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bulkUpload(BuildContext context) async {
    final courses = context.read<CoursesProvider>().items;
    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No courses yet. Add courses first.')),
      );
      return;
    }
    String selectedCourseId = courses.first.id;
    int sem = 1;
    final yearCtrl = TextEditingController(text: '${DateTime.now().year}');
    final files = await FilePicker.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (files == null || files.files.isEmpty) return;
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => StatefulBuilder(
            builder: (context, setLocal) => AlertDialog(
              title: const Text('Bulk Upload Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedCourseId,
                    items: courses
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.data()['courseCode']} - ${c.data()['courseTitle']}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setLocal(() => selectedCourseId = v ?? selectedCourseId),
                    decoration: const InputDecoration(labelText: 'Course'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: yearCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Year'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: sem,
                    items: const [1, 2]
                        .map((e) => DropdownMenuItem(value: e, child: Text('Semester $e')))
                        .toList(),
                    onChanged: (v) => setLocal(() => sem = v ?? sem),
                    decoration: const InputDecoration(labelText: 'Semester'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Start')),
              ],
            ),
          ),
        ) ??
        false;
    if (!ok) return;
    final courseDoc = courses.firstWhere((c) => c.id == selectedCourseId);
    final course = {'id': courseDoc.id, ...courseDoc.data()};
    final year = int.tryParse(yearCtrl.text.trim()) ?? DateTime.now().year;
    final upload = context.read<UploadProvider>();
    final p = context.read<PastQuestionsProvider>();
    for (final f in files.files) {
      try {
        final r2Path = await upload.uploadPdf(
          file: f,
          courseCode: course['courseCode'].toString(),
          year: year,
          semester: sem,
        );
        final base = f.name.replaceAll('.pdf', '');
        await p.addPastQuestion(
          course: course,
          year: year,
          semester: sem,
          title: '${course['courseCode']} $base',
          r2Path: r2Path,
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bulk upload error on ${f.name}: $e')),
        );
      }
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bulk upload complete (${files.files.length} files).')),
    );
  }

  Future<void> _showPastQuestionForm(
    BuildContext context, {
    String? docId,
    Map<String, dynamic>? initial,
  }) async {
    final form = GlobalKey<FormState>();
    final title = TextEditingController(text: initial?['title']?.toString() ?? '');
    int year = (initial?['year'] as num?)?.toInt() ?? DateTime.now().year;
    int sem = (initial?['semester'] as num?)?.toInt() ?? 1;
    PlatformFile? file;
    String? existingR2Path = initial?['r2Path']?.toString();
    String? selectedCourseId = initial?['courseId']?.toString();
    Map<String, dynamic>? selectedCourse;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final courses = context.watch<CoursesProvider>().items;
        if (selectedCourseId != null) {
          for (final c in courses) {
            if (c.id == selectedCourseId) {
              selectedCourse = {'id': c.id, ...c.data()};
              break;
            }
          }
        }
        return StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: Text(docId == null ? 'Add Past Question' : 'Edit Past Question'),
            content: SizedBox(
              width: 520,
              child: Form(
                key: form,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedCourseId,
                        decoration: const InputDecoration(labelText: 'Course'),
                        items: courses
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text('${c.data()['courseCode']} - ${c.data()['courseTitle']}'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setLocal(() {
                            selectedCourseId = v;
                            final doc = courses.firstWhere((e) => e.id == v);
                            selectedCourse = {'id': doc.id, ...doc.data()};
                            if (title.text.trim().isEmpty) {
                              title.text = '${doc.data()['courseCode']} Past Question $year';
                            }
                          });
                        },
                        validator: (v) => v == null || v.isEmpty ? 'Select a course' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: title,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: '$year',
                        decoration: const InputDecoration(labelText: 'Year'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => year = int.tryParse(v) ?? year,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        initialValue: sem,
                        items: const [1, 2]
                            .map((e) => DropdownMenuItem(value: e, child: Text('Semester $e')))
                            .toList(),
                        onChanged: (v) => sem = v ?? sem,
                        decoration: const InputDecoration(labelText: 'Semester'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              file?.name ??
                                  (existingR2Path == null
                                      ? 'No PDF selected'
                                      : 'Current: $existingR2Path'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              final res = await FilePicker.pickFiles(
                                withData: true,
                                type: FileType.custom,
                                allowedExtensions: const ['pdf'],
                              );
                              if (res != null && res.files.isNotEmpty) {
                                setLocal(() => file = res.files.first);
                              }
                            },
                            child: Text(docId == null ? 'Pick PDF' : 'Replace PDF'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  if (!form.currentState!.validate()) return;
                  if (selectedCourse == null && docId == null) return;
                  try {
                    final upload = context.read<UploadProvider>();
                    final provider = context.read<PastQuestionsProvider>();
                    String? newR2;
                    if (file != null && selectedCourse != null) {
                      newR2 = await upload.uploadPdf(
                        file: file!,
                        courseCode: selectedCourse!['courseCode'].toString(),
                        year: year,
                        semester: sem,
                      );
                    }

                    if (docId == null) {
                      if (newR2 == null) {
                        throw Exception('Please select a PDF file.');
                      }
                      await provider.addPastQuestion(
                        course: selectedCourse!,
                        year: year,
                        semester: sem,
                        title: title.text.trim(),
                        r2Path: newR2,
                      );
                    } else {
                      if (newR2 != null && existingR2Path != null && existingR2Path.isNotEmpty) {
                        await upload.deletePdf(existingR2Path);
                      }
                      await provider.updatePastQuestion(
                        id: docId,
                        year: year,
                        semester: sem,
                        title: title.text.trim(),
                        r2Path: newR2,
                      );
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved successfully')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Save failed: $e')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}

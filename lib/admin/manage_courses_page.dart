import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:past_questions/providers/courses_provider.dart';
import 'package:past_questions/providers/departments_provider.dart';
import 'package:provider/provider.dart';

class ManageCoursesPage extends StatefulWidget {
  const ManageCoursesPage({super.key});

  @override
  State<ManageCoursesPage> createState() => _ManageCoursesPageState();
}

class _ManageCoursesPageState extends State<ManageCoursesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoursesProvider>().refresh();
      context.read<DepartmentsProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CoursesProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Courses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourseForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by course code/title',
                border: OutlineInputBorder(),
              ),
              onChanged: courses.setSearch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showBulkImportDialog(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Bulk Import CSV/JSON'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: courses.refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: courses.items.length + (courses.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= courses.items.length) {
                    return Center(
                      child: TextButton(
                        onPressed: courses.loading ? null : () => courses.fetchNext(),
                        child: Text(courses.loading ? 'Loading...' : 'Load more'),
                      ),
                    );
                  }
                  final doc = courses.items[index];
                  final m = doc.data();
                  return Card(
                    child: ListTile(
                      title: Text(
                        '${m['courseCode'] ?? ''} - ${m['courseTitle'] ?? ''}',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${m['departmentName'] ?? ''} | ${m['facultyName'] ?? ''} | '
                        'Level ${m['year'] ?? ''} | Sem ${m['semester'] ?? ''}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'edit') {
                            await _showCourseForm(context, docId: doc.id, initial: m);
                          } else {
                            final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete course?'),
                                    content: const Text(
                                      'This can also remove linked past questions.',
                                    ),
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
                            if (ok) {
                              await courses.deleteCourse(doc.id, cascadePastQuestions: true);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Course deleted')),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
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

  Future<void> _showBulkImportDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bulk Import'),
        content: SizedBox(
          width: 600,
          child: TextField(
            controller: ctrl,
            maxLines: 12,
            decoration: const InputDecoration(
              hintText: 'Paste CSV (header row) or JSON array here',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await context.read<CoursesProvider>().bulkImportFromString(ctrl.text);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bulk import complete')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Import failed: $e')),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCourseForm(
    BuildContext context, {
    String? docId,
    Map<String, dynamic>? initial,
  }) async {
    final form = GlobalKey<FormState>();
    final code = TextEditingController(text: initial?['courseCode']?.toString() ?? '');
    final title = TextEditingController(text: initial?['courseTitle']?.toString() ?? '');
    String? dept = initial?['departmentName']?.toString();
    String? fac = initial?['facultyName']?.toString();
    int year = (initial?['year'] as num?)?.toInt() ?? 100;
    int sem = (initial?['semester'] as num?)?.toInt() ?? 1;
    await showDialog<void>(
      context: context,
      builder: (_) {
        final depProv = context.watch<DepartmentsProvider>();
        final depNames = depProv.departments
            .map((d) => d.data()['name']?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
        final facNames = depProv.faculties
            .map((d) => d.data()['name']?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
        if (dept != null && !depNames.contains(dept)) depNames.add(dept!);
        if (fac != null && !facNames.contains(fac)) facNames.add(fac!);
        return AlertDialog(
          title: Text(docId == null ? 'Add Course' : 'Edit Course'),
          content: SizedBox(
            width: 460,
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: code,
                    decoration: const InputDecoration(labelText: 'Course Code'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Course Title'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: year,
                    items: const [100, 200, 300, 400]
                        .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (v) => year = v ?? year,
                    decoration: const InputDecoration(labelText: 'Year / Level'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: sem,
                    items: const [1, 2]
                        .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (v) => sem = v ?? sem,
                    decoration: const InputDecoration(labelText: 'Semester'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: dept,
                    items: depNames
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => dept = v,
                    decoration: const InputDecoration(labelText: 'Department'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: fac,
                    items: facNames
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => fac = v,
                    decoration: const InputDecoration(labelText: 'Faculty'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (!form.currentState!.validate()) return;
                final payload = {
                  'courseCode': code.text.trim().toUpperCase(),
                  'courseTitle': title.text.trim(),
                  'year': year,
                  'semester': sem,
                  'departmentName': dept,
                  'facultyName': fac,
                };
                if (docId == null) {
                  await context.read<CoursesProvider>().addCourse(payload);
                } else {
                  await context.read<CoursesProvider>().updateCourse(docId, payload);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

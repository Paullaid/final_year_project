import 'package:flutter/material.dart';
import 'package:past_questions/providers/departments_provider.dart';
import 'package:provider/provider.dart';

class ManageDepartmentsPage extends StatefulWidget {
  const ManageDepartmentsPage({super.key});

  @override
  State<ManageDepartmentsPage> createState() => _ManageDepartmentsPageState();
}

class _ManageDepartmentsPageState extends State<ManageDepartmentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentsProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DepartmentsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Departments & Faculties')),
      body: RefreshIndicator(
        onRefresh: p.refresh,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => _addName(context, isDepartment: true),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Department'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _addName(context, isDepartment: false),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Faculty'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Departments', style: TextStyle(fontWeight: FontWeight.w700)),
            ...p.departments.map((d) {
              final name = d.data()['name']?.toString() ?? '';
              return Card(
                child: ListTile(
                  title: Text(name),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        _editName(context, id: d.id, old: name, isDepartment: true);
                      } else {
                        await p.deleteDepartment(d.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            const Text('Faculties', style: TextStyle(fontWeight: FontWeight.w700)),
            ...p.faculties.map((d) {
              final name = d.data()['name']?.toString() ?? '';
              return Card(
                child: ListTile(
                  title: Text(name),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        _editName(context, id: d.id, old: name, isDepartment: false);
                      } else {
                        await p.deleteFaculty(d.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _addName(BuildContext context, {required bool isDepartment}) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isDepartment ? 'Add Department' : 'Add Faculty'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              final p = context.read<DepartmentsProvider>();
              if (isDepartment) {
                await p.addDepartment(text);
              } else {
                await p.addFaculty(text);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(
    BuildContext context, {
    required String id,
    required String old,
    required bool isDepartment,
  }) async {
    final ctrl = TextEditingController(text: old);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isDepartment ? 'Edit Department' : 'Edit Faculty'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              final p = context.read<DepartmentsProvider>();
              if (isDepartment) {
                await p.updateDepartment(id, text);
              } else {
                await p.updateFaculty(id, text);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

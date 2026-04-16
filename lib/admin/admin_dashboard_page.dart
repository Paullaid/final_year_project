import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:past_questions/admin/manage_courses_page.dart';
import 'package:past_questions/admin/manage_departments_page.dart';
import 'package:past_questions/admin/manage_past_questions_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Future<Map<String, int>> _stats() async {
    final fs = FirebaseFirestore.instance;
    final courses = await fs.collection('courses').count().get();
    final past = await fs.collection('pastQuestions').count().get();
    final recent = await fs
        .collection('pastQuestions')
        .where(
          'uploadedAt',
          isGreaterThan: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
        )
        .count()
        .get();
    return {
      'courses': courses.count ?? 0,
      'past': past.count ?? 0,
      'pdfs': past.count ?? 0,
      'recent': recent.count ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: FutureBuilder<Map<String, int>>(
        future: _stats(),
        builder: (context, snap) {
          final data = snap.data ??
              const {
                'courses': 0,
                'past': 0,
                'pdfs': 0,
                'recent': 0,
              };
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Overview',
                style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(label: 'Total Courses', value: '${data['courses']}'),
                  _StatCard(label: 'Past Questions', value: '${data['past']}'),
                  _StatCard(label: 'PDFs Uploaded', value: '${data['pdfs']}'),
                  _StatCard(label: 'Recent (7d)', value: '${data['recent']}'),
                ],
              ),
              const SizedBox(height: 22),
              Text('Quick Actions', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              _ActionButton(
                icon: Icons.menu_book_outlined,
                label: 'Manage Courses',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageCoursesPage()),
                ),
              ),
              _ActionButton(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Manage Past Questions',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManagePastQuestionsPage()),
                ),
              ),
              _ActionButton(
                icon: Icons.apartment_outlined,
                label: 'Manage Departments & Faculties',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageDepartmentsPage()),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'All admin actions require admin role and are logged by Firebase auth identity.',
                style: GoogleFonts.lato(color: scheme.onSurface.withOpacity(0.7)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.lightBlue.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(label, style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

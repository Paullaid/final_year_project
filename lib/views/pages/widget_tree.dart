import 'package:flutter/material.dart';
import 'package:past_questions/admin/admin_dashboard_page.dart';
import 'package:past_questions/admin/admin_guard.dart';
import 'package:past_questions/providers/admin_role_provider.dart';
import 'package:past_questions/providers/navigation_provider.dart';
import 'package:past_questions/providers/theme_provider.dart';
import 'package:past_questions/sync_wrapper.dart';
import 'package:past_questions/views/pages/search_page.dart';
import 'package:past_questions/views/pages/settings_page.dart';
import 'package:past_questions/views/widgets/navbar_widgets.dart';
import 'package:past_questions/views/pages/home_page.dart';
import 'package:past_questions/views/pages/profile_page.dart';
import 'package:provider/provider.dart';

List<Widget> pages = [
  const HomePage(),
  const SearchPage(),
  const ProfilePage(),
  SettingsPage(title: 'Settings'),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "IUO PAST QUESTIONS",
          style: TextStyle(color: const Color.fromARGB(255, 222, 229, 252)),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 25, 55, 224),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, theme, _) {
              return IconButton(
                onPressed: () => theme.toggleTheme(),
                icon: Icon(
                  theme.isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage(title: 'Settings Page');
                  },
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Consumer<AdminRoleProvider>(
            builder: (context, role, _) {
              return ListView(
                children: [
                  const DrawerHeader(child: Text("Welcome Back")),
                  const ListTile(title: Text("Hello Paul")),
                  if (role.isAdmin)
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined),
                      title: const Text('Admin Panel'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminGuard(child: AdminDashboardPage()),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
      body: SyncWrapper(
        child: Consumer<NavigationProvider>(
          builder: (context, nav, _) {
            return pages.elementAt(nav.currentIndex);
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(onPressed: () {}, child: Icon(Icons.add)),
          SizedBox(height: 10.0),
          FloatingActionButton(onPressed: () {}, child: Icon(Icons.qr_code_2)),
        ],
      ),
      bottomNavigationBar: NavbarWidgets(),
    );
  }
}

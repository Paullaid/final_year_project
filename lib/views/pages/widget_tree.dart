import 'package:flutter/material.dart';
import 'package:past_questions/data/notifiers.dart';
import 'package:past_questions/views/pages/search_page.dart';
import 'package:past_questions/views/pages/settings_page.dart';
import 'package:past_questions/views/widgets/navbar_widgets.dart';
import 'package:past_questions/views/pages/home_page.dart';
import 'package:past_questions/views/pages/profile_page.dart';

List<Widget> pages = [
  HomePage(),
  SearchPage(),
  ProfilePage(),
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
        //leading: Icon(Icons.person_3_rounded),
        backgroundColor: const Color.fromARGB(255, 25, 55, 224),
        actions: [
          IconButton(
            onPressed: () {
              isDarkModeNotifier.value = !isDarkModeNotifier.value;
            },
            icon: ValueListenableBuilder(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDarkMode, child) {
                return Icon(
                  isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage(title: 'Settings Page',);
                  },
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
       drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Text("Welcome Back")),
            ListTile(title: Text("Hello Paul")),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
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

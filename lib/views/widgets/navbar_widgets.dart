import 'package:flutter/material.dart';
import 'package:past_questions/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class NavbarWidgets extends StatelessWidget {
  const NavbarWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, nav, _) {
        return NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(
              icon: Icon(Icons.search_sharp),
              label: 'Search',
            ),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
          onDestinationSelected: nav.setIndex,
          selectedIndex: nav.currentIndex,
        );
      },
    );
  }
}

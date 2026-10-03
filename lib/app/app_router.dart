import 'package:flutter/material.dart';

import '../core/widgets/mode_switcher.dart';
import '../core/widgets/theme_toggle.dart';
import '../features/garage/presentation/garage_screen.dart';
import '../features/map/presentation/live_radar_screen.dart';
import '../features/mascots/presentation/mascot_home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/tours/presentation/tours_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  static const pages = <Widget>[
    MascotHomeScreen(),
    LiveRadarScreen(),
    GarageScreen(),
    ToursScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FEEL-IT',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        actions: [
          if (isWide) const ModeSwitcher(),
          const ThemeToggle(),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: pages[index],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pets), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.radar), label: 'Radar'),
          NavigationDestination(icon: Icon(Icons.two_wheeler), label: 'Garage'),
          NavigationDestination(icon: Icon(Icons.route), label: 'Tours'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

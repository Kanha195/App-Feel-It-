import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/mode_switcher.dart';
import '../core/widgets/theme_toggle.dart';
import '../features/map/presentation/captain_dashboard_screen.dart';
import '../features/garage/presentation/garage_screen.dart';
import '../features/map/presentation/live_radar_screen.dart';
import '../features/mechanic/presentation/mechanic_scanner_screen.dart';
import '../features/mascots/presentation/mascot_home_screen.dart';
import '../features/mascots/virtual_home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/tours/presentation/tours_screen.dart';
import '../shared/providers/app_state.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final captainMode = ref.watch(appModeProvider) == AppMode.captain;
    final pages = captainMode
        ? const <Widget>[
            CaptainDashboardScreen(),
            LiveRadarScreen(),
            MechanicScannerScreen(),
            ProfileScreen(),
          ]
        : const <Widget>[
            MascotHomeScreen(),
            VirtualHomeScreen(),
            LiveRadarScreen(),
            GarageScreen(),
            ToursScreen(),
            ProfileScreen(),
          ];
    final destinations = captainMode
        ? const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.flag), label: 'Captain'),
            NavigationDestination(icon: Icon(Icons.radar), label: 'Radar'),
            NavigationDestination(icon: Icon(Icons.build), label: 'Scanner'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ]
        : const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.pets), label: 'Home'),
            NavigationDestination(
              icon: Icon(Icons.home_work_rounded),
              label: 'Virtual home',
            ),
            NavigationDestination(icon: Icon(Icons.radar), label: 'Map'),
            NavigationDestination(
                icon: Icon(Icons.two_wheeler), label: 'Garage'),
            NavigationDestination(icon: Icon(Icons.route), label: 'Tours'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ];
    final selectedIndex = index.clamp(0, pages.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FEEL-IT',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          const ModeSwitcher(),
          const ThemeToggle(),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: pages[selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: destinations,
      ),
    );
  }
}

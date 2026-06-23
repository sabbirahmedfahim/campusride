import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'ride_history_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const Color kPrimaryColor = Color(0xFF10B981);
  static const Color kSurfaceColor = Color(0xFF051424);
  static const Color kCardColor = Color(0xFF111E2F);
  static const Color kAccentColor = Color(0xFF2DD4BF);

  final _pages = const [
    DashboardScreen(),
    RideHistoryScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurfaceColor,
      body: IndexedStack(
        index: _index, 
        children: _pages
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: kSurfaceColor,
          indicatorColor: kPrimaryColor.withOpacity(0.1),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: kPrimaryColor,
                letterSpacing: 0.2,
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.4),
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: kPrimaryColor, size: 26);
            }
            return IconThemeData(color: Colors.white.withOpacity(0.4), size: 26);
          }),
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined), 
              selectedIcon: Icon(Icons.home_filled), 
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined), 
              selectedIcon: Icon(Icons.history_rounded), 
              label: 'Rides',
            ),
            NavigationDestination(
              icon: Icon(Icons.leaderboard_outlined), 
              selectedIcon: Icon(Icons.leaderboard_rounded), 
              label: 'Ranking',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline), 
              selectedIcon: Icon(Icons.person_rounded), 
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
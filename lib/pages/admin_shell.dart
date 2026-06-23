import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_rides_screen.dart';
import 'admin_requests_screen.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: const _AdminShellBody(),
    );
  }
}

class _AdminShellBody extends StatefulWidget {
  const _AdminShellBody();

  @override
  State<_AdminShellBody> createState() => _AdminShellBodyState();
}

class _AdminShellBodyState extends State<_AdminShellBody> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const Color kPrimaryColor = Color(0xFF10B981);
  static const Color kSurfaceColor = Color(0xFF051424);
  static const Color kCardColor = Color(0xFF111E2F);
  static const Color kAccentColor = Color(0xFF2DD4BF);

  final _pages = const [
    AdminDashboardScreen(),
    AdminUsersScreen(),
    AdminRidesScreen(),
    AdminRequestsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurfaceColor,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: _pages,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kSurfaceColor,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Admin Panel',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.8,
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: kPrimaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: kPrimaryColor,
        unselectedLabelColor: Colors.white.withOpacity(0.4),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        overlayColor: WidgetStateProperty.all(kPrimaryColor.withOpacity(0.05)),
        dividerColor: Colors.white.withOpacity(0.05),
        tabs: const [
          Tab(
            icon: Icon(Icons.dashboard_outlined, size: 20),
            text: 'Stats',
          ),
          Tab(
            icon: Icon(Icons.people_outline, size: 20),
            text: 'Users',
          ),
          Tab(
            icon: Icon(Icons.directions_car_outlined, size: 20),
            text: 'Rides',
          ),
          Tab(
            icon: Icon(Icons.list_alt_outlined, size: 20),
            text: 'Requests',
          ),
        ],
      ),
    );
  }
}
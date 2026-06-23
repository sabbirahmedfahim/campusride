import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color kPrimaryColor = Color(0xFF10B981);
  static const Color kSurfaceColor = Color(0xFF051424);
  static const Color kCardColor = Color(0xFF111E2F);
  static const Color kAccentColor = Color(0xFF2DD4BF);

  @override
  void initState() {
    super.initState();
    context.read<AdminProvider>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final scale = (screenWidth / 390).clamp(0.85, 1.25);

    return Scaffold(
      backgroundColor: kSurfaceColor,
      appBar: AppBar(
        backgroundColor: kSurfaceColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20 * scale,
            letterSpacing: -0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadStats,
          color: kPrimaryColor,
          backgroundColor: kCardColor,
          child: _buildBody(provider, screenWidth, scale),
        ),
      ),
    );
  }

  Widget _buildBody(AdminProvider provider, double screenWidth, double scale) {
    if (provider.isLoadingStats) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    if (provider.stats == null) {
      return _buildEmptyState(scale);
    }

    final stats = provider.stats!;
    final horizontalPadding = 16.0 * scale;

    final cards = <_StatCardData>[
      _StatCardData(
        label: 'Total Users',
        value: stats['total_users'].toString(),
        icon: Icons.people_alt_rounded,
        color: kPrimaryColor,
      ),
      _StatCardData(
        label: 'Banned Users',
        value: stats['banned_users'].toString(),
        icon: Icons.block_rounded,
        color: Colors.redAccent,
      ),
      _StatCardData(
        label: 'Active Rides',
        value: stats['active_rides'].toString(),
        icon: Icons.directions_car_rounded,
        color: kAccentColor,
      ),
      _StatCardData(
        label: 'Active Requests',
        value: stats['active_requests'].toString(),
        icon: Icons.list_alt_rounded,
        color: Colors.orangeAccent,
      ),
      _StatCardData(
        label: 'Rides Today',
        value: stats['rides_today'].toString(),
        icon: Icons.today_rounded,
        color: Colors.blueAccent,
      ),
      _StatCardData(
        label: 'Requests Today',
        value: stats['requests_today'].toString(),
        icon: Icons.event_note_rounded,
        color: Colors.purpleAccent,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            12 * scale,
            horizontalPadding,
            24 * scale,
          ),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 190 * scale,
            mainAxisSpacing: 14 * scale,
            crossAxisSpacing: 14 * scale,
            childAspectRatio: 1.05,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return _StatCard(
              label: card.label,
              value: card.value,
              icon: card.icon,
              color: card.color,
              scale: scale,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(double scale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_chart_outlined_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 48 * scale,
            ),
            SizedBox(height: 12 * scale),
            Text(
              'No stats available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double scale;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.scale,
  });

  static const Color kCardColor = Color(0xFF111E2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(icon, color: color, size: 22 * scale),
          ),
          SizedBox(height: 10 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26 * scale,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
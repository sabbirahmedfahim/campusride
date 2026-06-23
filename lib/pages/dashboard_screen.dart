import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/chat_provider.dart';
import '../entities/ride.dart';
import '../entities/ride_request.dart';
import '../widgets/ride_card.dart';
import '../widgets/latest_ride_card.dart';
import '../widgets/ride_request_card.dart';
import 'direction_modal.dart';
import 'offer_ride_screen.dart';
import 'request_ride_screen.dart';
import 'ride_detail_screen.dart';
import 'notification_inbox_screen.dart';
import 'chat_inbox_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _cooldownTicker;

  static const Color kPrimaryColor = Color(0xFF10B981);
  static const Color kSurfaceColor = Color(0xFF051424);
  static const Color kCardColor = Color(0xFF111E2F);
  static const Color kAccentColor = Color(0xFF2DD4BF);

  @override
  void initState() {
    super.initState();
    final rideProvider = context.read<RideProvider>();
    rideProvider.loadDashboard();
    rideProvider.subscribeToFeed();
    rideProvider.subscribeToRequests();
    context.read<NotificationProvider>().refreshUnreadCount();

    final chatProvider = context.read<ChatProvider>();
    chatProvider.loadInbox();
    chatProvider.subscribeToInbox();

    _cooldownTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    context.read<RideProvider>().unsubscribeFeed();
    context.read<RideProvider>().unsubscribeRequests();
    context.read<ChatProvider>().unsubscribeInbox();
    _cooldownTicker?.cancel();
    super.dispose();
  }

  Future<void> _onOfferRideTapped() async {
    final direction = await showDirectionModal(context);
    if (direction == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OfferRideScreen(direction: direction)),
    );
  }

  Future<void> _onRequestRideTapped() async {
    final direction = await showDirectionModal(context);
    if (direction == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RequestRideScreen(direction: direction)),
    );
  }

  String _cooldownLabel(DateTime endsAt) {
    final remaining = endsAt.difference(DateTime.now());
    final mins = remaining.inMinutes.clamp(0, 999);
    return 'Available in $mins min';
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final chatProvider = context.watch<ChatProvider>();

    final myActiveRide = rideProvider.myActiveRide;
    final myActiveRequest = rideProvider.myActiveRequest;
    final cooldownEnd = rideProvider.myProfile?.cooldownEndsAt();

    return Scaffold(
      backgroundColor: kSurfaceColor,
      appBar: _buildAppBar(notifProvider, chatProvider),
      body: RefreshIndicator(
        onRefresh: rideProvider.loadDashboard,
        color: kPrimaryColor,
        backgroundColor: kCardColor,
        child: rideProvider.isLoading &&
                rideProvider.activeFeed.isEmpty &&
                rideProvider.activeRequests.isEmpty
            ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 12),
                  _buildOnlineStatus(),
                  const SizedBox(height: 20),
                  
                  if (myActiveRide != null || myActiveRequest != null)
                    _buildActiveManagementSection(myActiveRide, myActiveRequest, rideProvider)
                  else
                    _buildQuickActions(cooldownEnd),
                  
                  const SizedBox(height: 32),
                  _buildRouteDemandSection(rideProvider.activeRequests),
                  const SizedBox(height: 32),
                  _buildAvailableRidesSection(rideProvider, myActiveRide),
                  const SizedBox(height: 32),
                  _buildRideRequestsSection(rideProvider, myActiveRequest),
                  const SizedBox(height: 32),
                  _buildLatestRidesSection(rideProvider),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(NotificationProvider notif, ChatProvider chat) {
    return AppBar(
      backgroundColor: kSurfaceColor,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'CampusRide',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.8,
        ),
      ),
      actions: [
        _buildAppBarBadgeIcon(
          Icons.chat_bubble_outline_rounded,
          chat.hasUnread,
          null,
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatInboxScreen())),
        ),
        const SizedBox(width: 8),
        _buildAppBarBadgeIcon(
          Icons.notifications_none_rounded,
          notif.unreadCount > 0,
          '${notif.unreadCount}',
          () async {
            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationInboxScreen()));
            notif.refreshUnreadCount();
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildAppBarBadgeIcon(IconData icon, bool isVisible, String? label, VoidCallback onTap) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 26),
        ),
        if (isVisible)
          Positioned(
            right: 8,
            top: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: label != null 
                ? Text(label, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)
                : const SizedBox.shrink(),
            ),
          )
      ],
    );
  }

  Widget _buildOnlineStatus() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: kPrimaryColor,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Online',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActiveManagementSection(Ride? myRide, RideRequest? myRequest, RideProvider provider) {
    bool isRide = myRide != null;
    String title = isRide ? 'Your Active Ride' : 'Your Active Request';
    String subtitle = isRide 
        ? '${myRide.directionLabel} • ${myRide.vehicleType.toUpperCase()}' 
        : '${myRequest?.directionLabel ?? ""} • ${myRequest?.routesLabel ?? ""}';
    
    Color accentColor = isRide ? kPrimaryColor : kAccentColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              _buildLiveBadge(accentColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  isRide ? 'Booked' : 'Found a Ride', 
                  accentColor, 
                  Colors.black, 
                  onPressed: () async {
                    bool ok = isRide 
                        ? await provider.markBooked(myRide.id)
                        : (myRequest != null ? await provider.markRequestCompleted(myRequest.id) : false);
                    if (!ok && mounted) _showError(provider.error);
                  }
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Cancel', 
                  Colors.white.withOpacity(0.08), 
                  Colors.white, 
                  onPressed: () async {
                    bool ok = isRide 
                        ? await provider.markCancelled(myRide.id)
                        : (myRequest != null ? await provider.markRequestCancelled(myRequest.id) : false);
                    if (!ok && mounted) _showError(provider.error);
                  }
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(Icons.sensors, size: 14, color: color),
          const SizedBox(width: 4),
          Text('LIVE', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(DateTime? cooldownEnd) {
    final inCooldown = cooldownEnd != null;
    final cooldownText = inCooldown ? _cooldownLabel(cooldownEnd) : null;

    return Row(
      children: [
        Expanded(
          child: _buildSquareAction(
            inCooldown ? cooldownText! : 'Offer Ride', 
            'Share journey', 
            Icons.directions_car_filled_rounded, 
            kPrimaryColor,
            onTap: inCooldown ? null : _onOfferRideTapped
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSquareAction(
            inCooldown ? cooldownText! : 'Request Ride', 
            'Need a lift', 
            Icons.person_search_rounded, 
            kCardColor,
            onTap: inCooldown ? null : _onRequestRideTapped
          ),
        ),
      ],
    );
  }

  Widget _buildSquareAction(String title, String subtitle, IconData icon, Color color, {VoidCallback? onTap}) {
    bool isPrimary = color == kPrimaryColor;
    bool isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isPrimary && !isDisabled ? [BoxShadow(color: kPrimaryColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isPrimary ? Colors.black : kAccentColor, size: 30),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: TextStyle(color: isPrimary ? Colors.black : Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: isPrimary ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.4), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteDemandSection(List<RideRequest> requests) {
    final counts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0};
    for (final req in requests) {
      for (final r in req.routes) {
        counts[r] = (counts[r] ?? 0) + 1;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Route Demand', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Row(
          children: [1, 2, 3, 4].map((r) {
            final count = counts[r] ?? 0;
            return Expanded(child: _buildRouteChip(count.toString(), 'R$r', count > 0));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRouteChip(String count, String label, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: active ? kPrimaryColor.withOpacity(0.05) : kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active ? kPrimaryColor : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(color: active ? kPrimaryColor : Colors.white.withOpacity(0.3), fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAvailableRidesSection(RideProvider provider, Ride? myRide) {
    final feed = provider.activeFeed.where((r) => r.id != myRide?.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available Rides', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        if (feed.isEmpty)
          _buildEmptyState('No active rides right now.')
        else
          ...feed.map((ride) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RideCard(
              ride: ride,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RideDetailScreen(ride: ride))),
            ),
          )),
      ],
    );
  }

  Widget _buildRideRequestsSection(RideProvider provider, RideRequest? myRequest) {
    final feed = provider.activeRequests.where((r) => r.id != myRequest?.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ride Requests', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        if (feed.isEmpty)
          _buildEmptyState('No active requests right now.')
        else
          ...feed.map((req) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RideRequestCard(request: req),
          )),
      ],
    );
  }

  Widget _buildLatestRidesSection(RideProvider provider) {
    if (provider.latestRides.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Latest Rides', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.latestRides.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => LatestRideCard(ride: provider.latestRides[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(child: Text(message, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14))),
    );
  }

  Widget _buildActionButton(String text, Color bgColor, Color textColor, {required VoidCallback onPressed}) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        child: Text(text),
      ),
    );
  }

  void _showError(String? error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Operation failed'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
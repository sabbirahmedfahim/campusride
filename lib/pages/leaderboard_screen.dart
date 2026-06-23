import 'package:flutter/material.dart';
import '../api/leaderboard_api.dart';
import '../api/auth_api.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _api = LeaderboardApi();
  final _authApi = AuthApi();

  List<LeaderboardEntry> _top50 = [];
  LeaderboardEntry? _myRank;
  bool _loading = true;

  static const Color kPrimaryColor = Color(0xFF10B981);
  static const Color kSurfaceColor = Color(0xFF051424);
  static const Color kCardColor = Color(0xFF111E2F);
  static const Color kAccentColor = Color(0xFF2DD4BF);

  static const Color kRank1Color = Color(0xFF10B981);
  static const Color kRank2Color = Color(0xFF2DD4BF);
  static const Color kRank3Color = Color(0xFF7DD3C0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final top50 = await _api.fetchTop50();
      final myRank = await _api.fetchMyRank();
      if (mounted) {
        setState(() {
          _top50 = top50;
          _myRank = myRank;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _myRankInTop50 =>
      _myRank != null && _top50.any((e) => e.userId == _myRank!.userId);

  @override
  Widget build(BuildContext context) {
    final myId = _authApi.currentUserId;
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 390).clamp(0.85, 1.2);

    return Scaffold(
      backgroundColor: kSurfaceColor,
      appBar: _buildAppBar(scale),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
            : RefreshIndicator(
                onRefresh: _load,
                color: kPrimaryColor,
                backgroundColor: kCardColor,
                child: _top50.isEmpty
                    ? _buildEmptyState(scale)
                    : _buildContent(myId, scale),
              ),
      ),
    );
  }

  Widget _buildContent(String? myId, double scale) {
    final hasPodium = _top50.length >= 3;
    final restList = hasPodium ? _top50.sublist(3) : <LeaderboardEntry>[];

    return ListView(
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (hasPodium) _buildPodium(myId, scale) else _buildHeader(scale),
        if (!hasPodium)
          ..._top50.map((entry) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16 * scale, 0, 16 * scale, 8 * scale),
              child: _buildListRow(
                entry: entry,
                isCurrentUser: entry.userId == myId,
                scale: scale,
              ),
            );
          }),
        if (hasPodium) ...[
          SizedBox(height: 8 * scale),
          _buildSectionLabel(scale),
          ...restList.map((entry) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16 * scale, 0, 16 * scale, 8 * scale),
              child: _buildListRow(
                entry: entry,
                isCurrentUser: entry.userId == myId,
                scale: scale,
              ),
            );
          }),
        ],
        SizedBox(height: 12 * scale),
        if (_myRank != null && !_myRankInTop50) _buildMyRankSticky(scale),
        SizedBox(height: 24 * scale),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(double scale) {
    return AppBar(
      backgroundColor: kSurfaceColor,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Leaderboard',
        style: TextStyle(
          fontSize: 24 * scale,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.8,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20 * scale, 4 * scale, 20 * scale, 12 * scale),
      child: Row(
        children: [
          Icon(Icons.format_list_numbered_rounded,
              color: Colors.white.withOpacity(0.4), size: 16 * scale),
          SizedBox(width: 8 * scale),
          Text(
            'Other Contributors',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Container(
      padding: EdgeInsets.fromLTRB(20 * scale, 16 * scale, 20 * scale, 12 * scale),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: kPrimaryColor, size: 20 * scale),
          SizedBox(width: 8 * scale),
          Text(
            'Top Contributors',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(String? myId, double scale) {
    final first = _top50[0];
    final second = _top50[1];
    final third = _top50[2];

    return Container(
      padding: EdgeInsets.fromLTRB(16 * scale, 24 * scale, 16 * scale, 28 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kPrimaryColor.withOpacity(0.10),
            kSurfaceColor.withOpacity(0.0),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 14 * scale),
                  child: _PodiumSlot(
                    entry: second,
                    rankColor: kRank2Color,
                    avatarSize: 56 * scale,
                    isCurrentUser: second.userId == myId,
                    scale: scale,
                  ),
                ),
              ),
              Expanded(
                child: _PodiumSlot(
                  entry: first,
                  rankColor: kRank1Color,
                  avatarSize: 72 * scale,
                  isCurrentUser: first.userId == myId,
                  scale: scale,
                  showCrown: true,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24 * scale),
                  child: _PodiumSlot(
                    entry: third,
                    rankColor: kRank3Color,
                    avatarSize: 52 * scale,
                    isCurrentUser: third.userId == myId,
                    scale: scale,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _podiumBar(kRank2Color, 44 * scale, scale)),
              SizedBox(width: 6 * scale),
              Expanded(child: _podiumBar(kRank1Color, 60 * scale, scale)),
              SizedBox(width: 6 * scale),
              Expanded(child: _podiumBar(kRank3Color, 32 * scale, scale)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _podiumBar(Color color, double height, double scale) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.35), color.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10 * scale)),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildListRow({
    required LeaderboardEntry entry,
    required bool isCurrentUser,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: isCurrentUser ? kPrimaryColor.withOpacity(0.10) : kCardColor,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: isCurrentUser
              ? kPrimaryColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32 * scale,
            height: 32 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Container(
            width: 32 * scale,
            height: 32 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kAccentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              _initialOf(entry.fullName),
              style: TextStyle(
                color: kAccentColor,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              entry.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * scale,
                fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(
            '${entry.totalScore} pts',
            style: TextStyle(
              color: isCurrentUser ? kPrimaryColor : Colors.white.withOpacity(0.7),
              fontSize: 13 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankSticky(double scale) {
    final myRank = _myRank!;

    return Padding(
      padding: EdgeInsets.fromLTRB(16 * scale, 4 * scale, 16 * scale, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4 * scale, bottom: 8 * scale),
            child: Text(
              'Your Rank',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12 * scale,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(14 * scale),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: kPrimaryColor.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32 * scale,
                  height: 32 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${myRank.rank}',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Container(
                  width: 32 * scale,
                  height: 32 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _initialOf(myRank.fullName),
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Text(
                    myRank.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                Text(
                  '${myRank.totalScore} pts',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.military_tech_outlined,
              size: 64 * scale, color: Colors.white.withOpacity(0.1)),
          SizedBox(height: 16 * scale),
          Text(
            'No completed rides yet.',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16 * scale),
          ),
        ],
      ),
    );
  }
}

String _initialOf(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed[0].toUpperCase();
}

class _PodiumSlot extends StatelessWidget {
  final LeaderboardEntry entry;
  final Color rankColor;
  final double avatarSize;
  final bool isCurrentUser;
  final double scale;
  final bool showCrown;

  const _PodiumSlot({
    required this.entry,
    required this.rankColor,
    required this.avatarSize,
    required this.isCurrentUser,
    required this.scale,
    this.showCrown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCrown)
          Padding(
            padding: EdgeInsets.only(bottom: 4 * scale),
            child: Icon(Icons.workspace_premium_rounded,
                color: rankColor, size: 22 * scale),
          ),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    rankColor.withOpacity(0.35),
                    rankColor.withOpacity(0.12),
                  ],
                ),
                border: Border.all(
                  color: isCurrentUser ? Colors.white : rankColor,
                  width: isCurrentUser ? 2.5 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: rankColor.withOpacity(0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _initialOf(entry.fullName),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: avatarSize * 0.36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              bottom: -6 * scale,
              child: Container(
                width: 22 * scale,
                height: 22 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rankColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF051424), width: 2),
                ),
                child: Text(
                  '${entry.rank}',
                  style: TextStyle(
                    color: const Color(0xFF051424),
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * scale),
        Text(
          entry.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2 * scale),
        Text(
          '${entry.totalScore} pts',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: rankColor,
            fontSize: 12 * scale,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
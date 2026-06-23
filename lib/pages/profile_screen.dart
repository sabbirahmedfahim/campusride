import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/ride_api.dart';
import '../entities/app_user.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'admin_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _rideApi = RideApi();
  AppUser? _profile;
  bool _loading = true;
  bool _editing = false;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  static const Color kPrimaryColor = Color(0xFF10B981);
  static const Color kSurfaceColor = Color(0xFF051424);
  static const Color kCardColor = Color(0xFF111E2F);
  static const Color kAccentColor = Color(0xFF2DD4BF);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final profile = await _rideApi.getMyProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _nameCtrl.text = profile.fullName;
          _phoneCtrl.text = profile.phone;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    await _rideApi.updateProfile(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    setState(() => _editing = false);
    _load();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _profile == null) {
      return const Scaffold(
        backgroundColor: kSurfaceColor,
        body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: kSurfaceColor,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderSection(_profile!),
                    const SizedBox(height: 40),
                    _buildStatsSection(_profile!),
                    const SizedBox(height: 40),
                    _buildDetailsSection(),
                    const SizedBox(height: 48),
                    _buildActionButtons(_profile!),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kSurfaceColor,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.8,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => setState(() => _editing = !_editing),
          icon: Icon(_editing ? Icons.close_rounded : Icons.edit_rounded, color: kPrimaryColor),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderSection(AppUser profile) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kPrimaryColor.withOpacity(0.3), width: 2),
          ),
          child: CircleAvatar(
            radius: 54,
            backgroundColor: kCardColor,
            child: Text(
              profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 36,
                color: kPrimaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          profile.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            profile.email,
            style: const TextStyle(
              color: kPrimaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(AppUser profile) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Score',
            '${profile.totalScore}',
            'pts',
            Icons.stars_rounded,
            kPrimaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '${profile.ridesCompleted}',
            'rides',
            Icons.directions_car_rounded,
            kAccentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField('Full Name', _nameCtrl, Icons.person_outline_rounded, _editing),
        const SizedBox(height: 16),
        _buildTextField('Phone Number', _phoneCtrl, Icons.phone_android_rounded, _editing),
        const SizedBox(height: 16),
        _buildTextField('Gender', TextEditingController(text: _profile!.gender), Icons.wc_rounded, false),
        const SizedBox(height: 16),
        _buildTextField('Email Address', TextEditingController(text: _profile!.email), Icons.alternate_email_rounded, false),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isEnabled) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: isEnabled ? kPrimaryColor : Colors.white.withOpacity(0.3), size: 22),
        filled: true,
        fillColor: isEnabled ? kPrimaryColor.withOpacity(0.05) : kCardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppUser profile) {
    return Column(
      children: [
        if (_editing) ...[
          _buildPrimaryButton('Save Changes', kPrimaryColor, Colors.black, _save),
          const SizedBox(height: 16),
        ],
        if (profile.isAdmin) ...[
          _buildPrimaryButton(
            'Admin Panel', 
            kCardColor, 
            kAccentColor, 
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShell())),
            icon: Icons.admin_panel_settings_rounded
          ),
          const SizedBox(height: 16),
        ],
        _buildSecondaryButton('Logout', Colors.redAccent.withOpacity(0.1), Colors.redAccent, _logout, Icons.logout_rounded),
      ],
    );
  }

  Widget _buildPrimaryButton(String text, Color bgColor, Color textColor, VoidCallback onTap, {IconData? icon}) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, Color bgColor, Color textColor, VoidCallback onTap, IconData icon) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          side: BorderSide(color: textColor.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF10B981);
const Color kSurfaceColor = Color(0xFF051424);
const Color kCardColor    = Color(0xFF111E2F);
const Color kAccentColor  = Color(0xFF2DD4BF);

Future<String?> showDirectionModal(BuildContext context) {
  final double screenWidth = MediaQuery.of(context).size.width;
  final bool isWideScreen = screenWidth >= 600;

  if (isWideScreen) {
    return _showDirectionDialog(context);
  } else {
    return _showDirectionSheet(context);
  }
}

Future<String?> _showDirectionDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
          decoration: BoxDecoration(
            color: kSurfaceColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'Choose Direction',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(null),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withOpacity(0.5),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Select your travel route to see relevant rides.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              _DirectionCard(
                icon: Icons.north_east_rounded,
                label: 'From Leading University',
                subtitle: 'Campus to Sylhet City',
                iconColor: kPrimaryColor,
                onTap: () => Navigator.of(ctx).pop('from_lu'),
              ),
              const SizedBox(height: 16),
              _DirectionCard(
                icon: Icons.south_west_rounded,
                label: 'To Leading University',
                subtitle: 'City to LU Campus',
                iconColor: kAccentColor,
                onTap: () => Navigator.of(ctx).pop('to_lu'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<String?> _showDirectionSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: kSurfaceColor,
    barrierColor: Colors.black.withOpacity(0.6),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (ctx) => SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Choose Direction',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your travel route to see relevant rides.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            _DirectionCard(
              icon: Icons.north_east_rounded,
              label: 'From Leading University',
              subtitle: 'Campus to Sylhet City',
              iconColor: kPrimaryColor,
              onTap: () => Navigator.of(ctx).pop('from_lu'),
            ),
            const SizedBox(height: 16),
            _DirectionCard(
              icon: Icons.south_west_rounded,
              label: 'To Leading University',
              subtitle: 'City to LU Campus',
              iconColor: kAccentColor,
              onTap: () => Navigator.of(ctx).pop('to_lu'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DirectionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _DirectionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: iconColor.withOpacity(0.1),
        highlightColor: iconColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.2),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:math';

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Wave Background
          _buildWaveBackground(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Settings List
                Expanded(child: _buildSettingsList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBackground() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
          painter: WavePainter(_waveController.value),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'Profile Information',
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.receipt_long_outlined,
              title: 'Statements & Documents',
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle('Preferences'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.palette_outlined,
              title: 'Appearance',
            ),
            _buildDivider(),
            _buildSettingItem(icon: Icons.language_outlined, title: 'Language'),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle('Security'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.fingerprint_outlined,
              title: 'Face ID & Biometrics',
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.devices_outlined,
              title: 'Manage Devices',
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle('Support'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.help_outline_outlined,
              title: 'Help Center',
            ),
            _buildDivider(),
            _buildSettingItem(icon: Icons.chat_outlined, title: 'Contact Us'),
          ]),

          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black.withOpacity(0.6),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black.withOpacity(0.8)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.black.withOpacity(0.4)),
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 0,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.black.withOpacity(0.1),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(
          Icons.logout_outlined,
          color: Colors.black.withOpacity(0.8),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
        onTap: () {},
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

// In your settings_screen.dart, just update the WavePainter to use the same drawing method:
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final paint2 = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paint3 = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // First wave - slow (same timing as home screen)
    _drawWave(
      canvas,
      size,
      paint1,
      animationValue * 2 * pi,
      0.15,
      waveHeight: 40,
    );

    // Second wave - medium (same timing as home screen)
    _drawWave(
      canvas,
      size,
      paint2,
      -animationValue * 2 * pi,
      0.3,
      waveHeight: 30,
    );

    // Third wave - fast (same timing as home screen)
    _drawWave(
      canvas,
      size,
      paint3,
      animationValue * 4 * pi,
      0.45,
      waveHeight: 50,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    Paint paint,
    double phase,
    double verticalPosition, {
    double waveHeight = 40,
  }) {
    final path = Path();
    final baseY = size.height * verticalPosition;

    path.moveTo(0, baseY);

    for (double x = 0; x <= size.width; x += 5) {
      final y = baseY + sin((x / size.width * 4 * pi) + phase) * waveHeight;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

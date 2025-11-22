import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ravera/features/home/bloc/user_bloc.dart';
import 'package:ravera/features/home/bloc/user_profile.dart';
import 'package:ravera/features/home/bloc/user_state.dart';
import 'package:ravera/features/home/repository/user_profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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
    return BlocProvider(
      create: (context) => UserProfileBloc(
        repository: UserProfileRepository(supabase: Supabase.instance.client),
      )..add(FetchUserProfile()),
      child: Scaffold(
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

                  // Balance Section
                  Expanded(child: _buildBalanceSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveBackground() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white.withAlpha(210),
                Colors.white.withAlpha(190),
              ],
            ),
          ),
          child: CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: HomeWavePainter(_waveController.value),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        String userName = 'User';
        String greeting = 'Hello';

        if (state is UserProfileLoaded) {
          userName = state.userProfile.displayName;
          greeting = state.userProfile.greeting;
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User Info
              Row(
                children: [
                  BlocBuilder<UserProfileBloc, UserProfileState>(
                    builder: (context, state) {
                      String? avatarUrl;
                      if (state is UserProfileLoaded) {
                        avatarUrl = state.userProfile.avatarUrl;
                      }

                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          image: avatarUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(avatarUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: avatarUrl == null
                            ? Icon(Icons.person, color: Colors.white, size: 20)
                            : null,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, $userName',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Welcome back',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),

              // Notification Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withAlpha(22)),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'BALANCE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black.withAlpha(133),
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '\$12,450.77',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontFamily: 'Inter',
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class HomeWavePainter extends CustomPainter {
  final double animationValue;

  HomeWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.black.withAlpha(22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final paint2 = Paint()
      ..color = Colors.black.withAlpha(15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paint3 = Paint()
      ..color = Colors.black.withAlpha(10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final paint4 = Paint()
      ..color = Colors.black.withAlpha(22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // First wave - slow
    _drawWave(
      canvas,
      size,
      paint1,
      animationValue * 2 * pi,
      0.15,
      waveHeight: 40,
    );

    // Second wave - medium
    _drawWave(
      canvas,
      size,
      paint2,
      -animationValue * 2 * pi,
      0.3,
      waveHeight: 30,
    );

    // Third wave - fast
    _drawWave(
      canvas,
      size,
      paint3,
      animationValue * 4 * pi,
      0.45,
      waveHeight: 50,
    );

    // Fourth wave - medium speed
    _drawWave(
      canvas,
      size,
      paint4,
      -animationValue * 3 * pi,
      0.6,
      waveHeight: 35,
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
  bool shouldRepaint(covariant HomeWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

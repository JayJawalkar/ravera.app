// features/usage/views/usage_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shimmer/shimmer.dart';
import '../bloc/usage_bloc.dart';

class UsageScreen extends StatelessWidget {
  const UsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsageBloc()..add(const UsagePermissionChecked()),
      child: const _UsageView(),
    );
  }
}

class _UsageView extends StatefulWidget {
  const _UsageView();

  @override
  State<_UsageView> createState() => _UsageViewState();
}

class _UsageViewState extends State<_UsageView>
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
    return BlocBuilder<UsageBloc, UsageState>(
      builder: (context, state) {
        if (!state.hasPermission) {
          return _buildPermissionRequest(context);
        }

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
                    // App Bar
                    _buildAppBar(),

                    // Content
                    Expanded(
                      child: state.status == UsageStatus.loading
                          ? const _UsageShimmer()
                          : const _UsageContent(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
          painter: UsageWavePainter(_waveController.value),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Digital Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildPermissionRequest(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Wave Background
          _buildWaveBackground(),

          // Permission Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insights, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  const Text(
                    'Usage Access Required',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'To show your app usage statistics, we need usage access permission.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.read<UsageBloc>().add(
                      const UsagePermissionRequested(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UsageWavePainter extends CustomPainter {
  final double animationValue;

  UsageWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final paint2 = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paint3 = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final paint4 = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // First wave - slow (same timing as other screens)
    _drawWave(
      canvas,
      size,
      paint1,
      animationValue * 2 * pi,
      0.15,
      waveHeight: 40,
    );

    // Second wave - medium (same timing as other screens)
    _drawWave(
      canvas,
      size,
      paint2,
      -animationValue * 2 * pi,
      0.3,
      waveHeight: 30,
    );

    // Third wave - fast (same timing as other screens)
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
  bool shouldRepaint(covariant UsageWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _UsageShimmer extends StatelessWidget {
  const _UsageShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeFrameSelectorShimmer(),
          _UsageGraphShimmer(),
          _StatsRowShimmer(),
          _AppUsageBreakdownShimmer(),
        ],
      ),
    );
  }
}

class _TimeFrameSelectorShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('   ', style: TextStyle(fontSize: 14)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UsageGraphShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 120, height: 20, color: Colors.white),
            const SizedBox(height: 16),
            Container(width: 80, height: 28, color: Colors.white),
            const SizedBox(height: 24),
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 100, height: 16, color: Colors.white),
                        Container(width: 60, height: 16, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRowShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 80, height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 60, height: 24, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 80, height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 24, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppUsageBreakdownShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 160, height: 20, color: Colors.white),
          const SizedBox(height: 12),
          ...List.generate(
            6,
            (index) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(width: 80, height: 14, color: Colors.white),
                        ],
                      ),
                    ),
                    Container(width: 60, height: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageContent extends StatelessWidget {
  const _UsageContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _TimeFrameSelector(),
          _UsageGraph(),
          _StatsRow(),
          _AppUsageBreakdown(),
        ],
      ),
    );
  }
}

class _TimeFrameSelector extends StatelessWidget {
  const _TimeFrameSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsageBloc, UsageState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.1)),
          ),
          child: Row(
            children: ['Day', 'Week', 'Month'].map((timeFrame) {
              final isSelected = state.selectedTimeFrame == timeFrame;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.read<UsageBloc>().add(
                      UsageTimeFrameChanged(timeFrame),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.black45
                              : Colors.transparent,
                        ),
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          timeFrame,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey[600],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _UsageGraph extends StatelessWidget {
  const _UsageGraph();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsageBloc, UsageState>(
      builder: (context, state) {
        final totalMinutes = state.totalUsageTime ~/ 60000;
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        final timeText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${state.selectedTimeFrame} Usage',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insights,
                          size: 14,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${state.usageStats.length} Apps',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _CategoryChart(categoryBreakdown: state.categoryBreakdown),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final Map<String, int> categoryBreakdown;

  const _CategoryChart({required this.categoryBreakdown});

  @override
  Widget build(BuildContext context) {
    final maxTime = categoryBreakdown.values.fold(
      0,
      (max, time) => time > max ? time : max,
    );

    if (categoryBreakdown.isEmpty) {
      return const Text('No usage data available');
    }

    return Column(
      children: categoryBreakdown.entries.map((entry) {
        final percentage = maxTime > 0 ? (entry.value / maxTime) : 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    _formatDuration(entry.value),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 8,
                    width: percentage * MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(entry.key),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Social Networking':
        return Colors.blue;
      case 'Entertainment':
        return Colors.purple;
      case 'Games':
        return Colors.green;
      case 'Productivity':
        return Colors.orange;
      case 'Communication':
        return Colors.red;
      case 'Browser':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsageBloc, UsageState>(
      builder: (context, state) {
        final averagePerApp = state.usageStats.isNotEmpty
            ? state.totalUsageTime ~/ state.usageStats.length
            : 0;

        final mostUsedCategory = state.categoryBreakdown.isNotEmpty
            ? state.categoryBreakdown.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key
            : 'Social';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Avg. per App',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(averagePerApp),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Most Used',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mostUsedCategory,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _getCategoryColor(mostUsedCategory),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Social Networking':
        return Colors.blue;
      case 'Entertainment':
        return Colors.purple;
      case 'Games':
        return Colors.green;
      case 'Productivity':
        return Colors.orange;
      case 'Communication':
        return Colors.red;
      case 'Browser':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

class _AppUsageBreakdown extends StatelessWidget {
  const _AppUsageBreakdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsageBloc, UsageState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'App Usage Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              ...state.usageStats.take(6).map((usage) {
                final totalTime =
                    int.tryParse(usage.totalTimeInForeground ?? '0') ?? 0;
                return _AppUsageItem(
                  packageName: usage.packageName ?? '',
                  totalTime: totalTime,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _AppUsageItem extends StatelessWidget {
  final String packageName;
  final int totalTime;

  const _AppUsageItem({required this.packageName, required this.totalTime});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UsageBloc>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _AppIcon(packageName: packageName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getAppNameFromPackage(packageName, {}),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getAppCategory(bloc, packageName),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            _formatDuration(totalTime),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _getAppCategory(UsageBloc bloc, String packageName) {
    // Use the bloc's category detection
    return bloc.getAppCategory(packageName);
  }
}

class _AppIcon extends StatelessWidget {
  final String packageName;

  const _AppIcon({required this.packageName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsageBloc, UsageState>(
      builder: (context, state) {
        // Check if we have app info in the state's cache
        if (state.appInfoCache.containsKey(packageName)) {
          final app = state.appInfoCache[packageName] as AppInfo?;
          if (app?.icon != null) {
            return Image.memory(
              app!.icon!,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultAppIcon(packageName);
              },
            );
          }
        }
        return _buildDefaultAppIcon(packageName);
      },
    );
  }

  Widget _buildDefaultAppIcon(String packageName) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getColorFromPackage(packageName),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          _getAppInitials(packageName),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _getAppInitials(String packageName) {
    final appName = getAppNameFromPackage(packageName, {});
    if (appName.split(' ').length > 1) {
      return '${appName.split(' ')[0][0]}${appName.split(' ')[1][0]}'
          .toUpperCase();
    } else if (appName.length >= 2) {
      return appName.substring(0, 2).toUpperCase();
    } else if (appName.isNotEmpty) {
      return appName[0].toUpperCase();
    }
    return '?';
  }

  Color _getColorFromPackage(String packageName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final index = packageName.hashCode % colors.length;
    return colors[index];
  }
}

String _formatDuration(int milliseconds) {
  final duration = Duration(milliseconds: milliseconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  } else {
    return '${minutes}m';
  }
}

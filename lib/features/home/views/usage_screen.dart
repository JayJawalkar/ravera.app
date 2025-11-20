// features/usage/views/usage_screen.dart
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:usage_stats/usage_stats.dart';

class UsageScreen extends StatefulWidget {
  const UsageScreen({super.key});

  @override
  State<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  List<UsageInfo> _usageStats = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  String _selectedTimeFrame = 'Day';
  final Map<String, dynamic> _appInfoCache = {};
  final Map<String, String> _appCategories = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _initializeAppCategories();
  }

  void _initializeAppCategories() {
    // Common app categories mapping
    _appCategories.addAll({
      // Social
      'com.instagram.android': 'Social Networking',
      'com.facebook.katana': 'Social Networking',
      'com.twitter.android': 'Social Networking',
      'com.linkedin.android': 'Social Networking',
      'com.snapchat.android': 'Social Networking',
      'com.whatsapp': 'Social Networking',
      'com.tiktok.android': 'Social Networking',

      // Entertainment
      'com.google.android.youtube': 'Entertainment',
      'com.netflix.mediaclient': 'Entertainment',
      'com.spotify.music': 'Entertainment',
      'com.amazon.avod.thirdpartyclient': 'Entertainment',

      // Games
      'com.mojang.minecraftpe': 'Games',
      'com.roblox.client': 'Games',
      'com.epicgames.fortnite': 'Games',
      'com.supercell.clashofclans': 'Games',
      'com.mobile.legends': 'Games',
      'com.activision.callofduty.shooter': 'Games',
      'com.pubg.imobile': 'Games',
      // Productivity
      'com.google.android.apps.docs': 'Productivity',
      'com.microsoft.office.word': 'Productivity',
      'com.microsoft.office.excel': 'Productivity',
      'com.microsoft.office.powerpoint': 'Productivity',
      'com.dropbox.android': 'Productivity',
      'com.evernote': 'Productivity',

      // Communication
      'com.google.android.gm': 'Communication',
      'com.skype.raider': 'Communication',
      'com.discord': 'Communication',
      'com.slack': 'Communication',

      // Utilities
      'com.google.android.calculator': 'Utilities',
      'com.google.android.calendar': 'Utilities',
      'com.google.android.contacts': 'Utilities',

      // Browser
      'com.android.chrome': 'Browser',
      'com.sec.android.app.sbrowser': 'Browser',
      'com.opera.browser': 'Browser',
    });
  }

  Future<void> _checkPermissions() async {
    try {
      final bool hasAccess = await UsageStats.checkUsagePermission() ?? false;
      setState(() {
        _hasPermission = hasAccess;
        _isLoading = false;
      });

      if (hasAccess) {
        _fetchUsageStats();
      }
    } catch (e) {
      print('Error checking permission: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestUsagePermission() async {
    try {
      await UsageStats.grantUsagePermission();
      await Future.delayed(const Duration(seconds: 1));
      await _checkPermissions();
    } catch (e) {
      print('Error requesting permission: $e');
    }
  }

  Duration _getTimeFrameDuration() {
    switch (_selectedTimeFrame) {
      case 'Week':
        return const Duration(days: 7);
      case 'Month':
        return const Duration(days: 30);
      case 'Day':
      default:
        return const Duration(days: 1);
    }
  }

  Future<void> _fetchUsageStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final DateTime endDate = DateTime.now();
      final DateTime startDate = endDate.subtract(_getTimeFrameDuration());

      final List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
        startDate,
        endDate,
      );

      // Aggregate usage by package name to avoid duplicates
      final Map<String, UsageInfo> aggregatedStats = {};

      for (final usage in usageStats) {
        final packageName = usage.packageName ?? '';
        if (packageName.isEmpty) continue;

        final totalTime = int.tryParse(usage.totalTimeInForeground ?? '0') ?? 0;
        if (totalTime == 0) continue;

        if (aggregatedStats.containsKey(packageName)) {
          // Aggregate time for the same package
          final existing = aggregatedStats[packageName]!;
          final existingTime =
              int.tryParse(existing.totalTimeInForeground ?? '0') ?? 0;
          aggregatedStats[packageName] = UsageInfo(
            packageName: packageName,
            totalTimeInForeground: (existingTime + totalTime).toString(),
          );
        } else {
          aggregatedStats[packageName] = usage;
        }
      }

      final filteredStats = aggregatedStats.values.toList();

      filteredStats.sort((a, b) {
        final timeA = int.tryParse(a.totalTimeInForeground ?? '0') ?? 0;
        final timeB = int.tryParse(b.totalTimeInForeground ?? '0') ?? 0;
        return timeB.compareTo(timeA);
      });

      // Load app info for the top apps
      await _loadAppIcons(filteredStats.take(15).toList());

      setState(() {
        _usageStats = filteredStats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching usage stats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppIcons(List<UsageInfo> usageList) async {
    try {
      Set<String> packagesToFetch = usageList
          .map((usage) => usage.packageName ?? '')
          .where((packageName) => packageName.isNotEmpty)
          .toSet();

      for (String packageName in packagesToFetch) {
        if (!_appInfoCache.containsKey(packageName)) {
          try {
            AppInfo? app = await InstalledApps.getAppInfo(packageName);
            if (app != null) {
              _appInfoCache[packageName] = app;
            }
          } catch (e) {
            print('Error loading app info for $packageName: $e');
          }
        }
      }
    } catch (e) {
      print('Error in _loadAppIcons: $e');
    }
  }

  String _getAppCategory(String packageName) {
    // Try to get category from our mapping
    if (_appCategories.containsKey(packageName)) {
      return _appCategories[packageName]!;
    }

    // Fallback: guess category from package name or app name
    final appName = _getAppNameFromPackage(packageName).toLowerCase();

    if (appName.contains('game') ||
        appName.contains('clash') ||
        appName.contains('craft') ||
        appName.contains('legend') ||
        appName.contains('arena') ||
        appName.contains('battle')) {
      return 'Games';
    } else if (appName.contains('social') ||
        appName.contains('chat') ||
        appName.contains('message') ||
        appName.contains('connect') ||
        appName.contains('share')) {
      return 'Social Networking';
    } else if (appName.contains('video') ||
        appName.contains('movie') ||
        appName.contains('music') ||
        appName.contains('stream') ||
        appName.contains('tv')) {
      return 'Entertainment';
    } else if (appName.contains('work') ||
        appName.contains('office') ||
        appName.contains('doc') ||
        appName.contains('pdf') ||
        appName.contains('note')) {
      return 'Productivity';
    } else if (appName.contains('mail') ||
        appName.contains('email') ||
        appName.contains('contact') ||
        appName.contains('call')) {
      return 'Communication';
    } else if (appName.contains('browser') ||
        appName.contains('web') ||
        appName.contains('search')) {
      return 'Browser';
    }

    return 'Utilities';
  }

  Map<String, int> _getCategoryBreakdown() {
    final Map<String, int> categoryTimes = {};

    for (final usage in _usageStats) {
      final category = _getAppCategory(usage.packageName ?? '');
      final time = int.tryParse(usage.totalTimeInForeground ?? '0') ?? 0;

      categoryTimes[category] = (categoryTimes[category] ?? 0) + time;
    }

    return categoryTimes;
  }

  String _getMostUsedCategory() {
    final categoryTimes = _getCategoryBreakdown();
    if (categoryTimes.isEmpty) return 'Social';

    final mostUsed = categoryTimes.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return mostUsed.key;
  }

  int _getTotalUsageTime() {
    return _usageStats.fold(0, (total, usage) {
      return total + (int.tryParse(usage.totalTimeInForeground ?? '0') ?? 0);
    });
  }

  Widget _getAppIcon(String packageName) {
    if (_appInfoCache.containsKey(packageName)) {
      final AppInfo? app = _appInfoCache[packageName];
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
    final appName = _getAppNameFromPackage(packageName);
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

  String _getAppNameFromPackage(String packageName) {
    if (packageName.isEmpty) return 'Unknown App';

    String cleanedName = packageName;
    final prefixes = ['com.', 'org.', 'net.', 'io.', 'co.'];
    for (final prefix in prefixes) {
      if (cleanedName.startsWith(prefix)) {
        cleanedName = cleanedName.substring(prefix.length);
      }
    }

    final parts = cleanedName.split('.');
    String name = parts.isNotEmpty ? parts.last : cleanedName;
    name = name.replaceAll(RegExp(r'\.(android|mobile|app|beta|debug)$'), '');
    name = name.replaceAll('_', ' ').replaceAll('-', ' ');

    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1).toLowerCase();
    }

    // Handle specific app names
    if (packageName == 'com.google.android.youtube') return 'YouTube';
    if (packageName == 'com.instagram.android') return 'Instagram';
    if (packageName == 'com.facebook.katana') return 'Facebook';
    if (packageName == 'com.whatsapp') return 'WhatsApp';
    if (packageName == 'com.netflix.mediaclient') return 'Netflix';
    if (packageName == 'com.spotify.music') return 'Spotify';
    if (packageName == 'com.mobile.legends') return 'Mobile Legends';
    if (packageName == 'com.pubg.imobile') return 'BGMI';

    return name.isEmpty ? 'Unknown App' : name;
  }

  Widget _buildTimeFrameSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Day', 'Week', 'Month'].map((timeFrame) {
          final isSelected = _selectedTimeFrame == timeFrame;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeFrame = timeFrame;
                  });
                  _fetchUsageStats();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.black45 : Colors.transparent,
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
  }

  Widget _buildUsageGraph() {
    final totalTime = _getTotalUsageTime();
    final totalMinutes = totalTime ~/ 60000;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    String timeText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedTimeFrame Usage',
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insights, size: 14, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${_usageStats.length} Apps',
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
          _buildCategoryChart(),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    final categoryTimes = _getCategoryBreakdown();
    final maxTime = categoryTimes.values.fold(
      0,
      (max, time) => time > max ? time : max,
    );

    if (categoryTimes.isEmpty) {
      return const Text('No usage data available');
    }

    return Column(
      children: categoryTimes.entries.map((entry) {
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

  Widget _buildStatsRow() {
    final totalTime = _getTotalUsageTime();
    final averagePerApp = _usageStats.isNotEmpty
        ? totalTime ~/ _usageStats.length
        : 0;
    final mostUsedCategory = _getMostUsedCategory();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
  }

  Widget _buildAppUsageBreakdown() {
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
          ..._usageStats.take(6).map((usage) {
            final totalTime =
                int.tryParse(usage.totalTimeInForeground ?? '0') ?? 0;
            final appName = _getAppNameFromPackage(usage.packageName ?? '');
            final category = _getAppCategory(usage.packageName ?? '');

            return _buildAppItem(
              appName,
              category,
              totalTime,
              usage.packageName ?? '',
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAppItem(
    String appName,
    String category,
    int totalTime,
    String packageName,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _getAppIcon(packageName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category,
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

  Widget _buildPermissionRequest() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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
                onPressed: _requestUsagePermission,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return _buildPermissionRequest();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Digital Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeFrameSelector(),
                  _buildUsageGraph(),
                  _buildStatsRow(),
                  _buildAppUsageBreakdown(),
                ],
              ),
            ),
    );
  }
}

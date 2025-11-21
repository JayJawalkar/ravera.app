// features/usage/bloc/usage_bloc.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:usage_stats/usage_stats.dart';

part 'usage_event.dart';
part 'usage_state.dart';

class UsageBloc extends Bloc<UsageEvent, UsageState> {
  final Map<String, AppInfo> _appInfoCache = {};
  final Map<String, String> _appCategories = {};
  final Map<String, String> _appNameCache = {};

  UsageBloc() : super(const UsageState()) {
    on<UsagePermissionChecked>(_onPermissionChecked);
    on<UsagePermissionRequested>(_onPermissionRequested);
    on<UsageStatsFetched>(_onStatsFetched);
    on<UsageTimeFrameChanged>(_onTimeFrameChanged);

    _initializeAppCategories();
  }

  void _initializeAppCategories() {
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

  Future<void> _onPermissionChecked(
    UsagePermissionChecked event,
    Emitter<UsageState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UsageStatus.loading));

      final bool? hasAccess = await UsageStats.checkUsagePermission();
      final bool permissionGranted = hasAccess ?? false;

      if (permissionGranted) {
        add(const UsageStatsFetched());
      }

      emit(
        state.copyWith(
          status: UsageStatus.permissionChecked,
          hasPermission: permissionGranted,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UsageStatus.error,
          error: 'Error checking permission: $e',
        ),
      );
    }
  }

  Future<void> _onPermissionRequested(
    UsagePermissionRequested event,
    Emitter<UsageState> emit,
  ) async {
    try {
      await UsageStats.grantUsagePermission();
      await Future.delayed(const Duration(seconds: 1));
      add(const UsagePermissionChecked());
    } catch (e) {
      emit(
        state.copyWith(
          status: UsageStatus.error,
          error: 'Error requesting permission: $e',
        ),
      );
    }
  }

  Future<void> _onTimeFrameChanged(
    UsageTimeFrameChanged event,
    Emitter<UsageState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedTimeFrame: event.timeFrame,
        status: UsageStatus.loading,
      ),
    );
    add(const UsageStatsFetched());
  }

  Future<void> _onStatsFetched(
    UsageStatsFetched event,
    Emitter<UsageState> emit,
  ) async {
    try {
      final DateTime endDate = DateTime.now();
      final DateTime startDate = endDate.subtract(
        _getTimeFrameDuration(state.selectedTimeFrame),
      );

      final List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
        startDate,
        endDate,
      );

      final processedStats = await _processUsageStats(usageStats);

      // Convert app info cache for state
      final Map<String, dynamic> appInfoCacheForState = {};
      for (final entry in _appInfoCache.entries) {
        appInfoCacheForState[entry.key] = entry.value;
      }

      emit(
        state.copyWith(
          status: UsageStatus.success,
          usageStats: processedStats,
          totalUsageTime: _calculateTotalUsageTime(processedStats),
          categoryBreakdown: _calculateCategoryBreakdown(processedStats),
          appInfoCache: appInfoCacheForState,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UsageStatus.error,
          error: 'Error fetching usage stats: $e',
        ),
      );
    }
  }

  Future<List<UsageInfo>> _processUsageStats(List<UsageInfo> usageStats) async {
    final Map<String, UsageInfo> aggregatedStats = {};

    for (final usage in usageStats) {
      final packageName = usage.packageName ?? '';
      if (packageName.isEmpty) continue;

      final totalTime = int.tryParse(usage.totalTimeInForeground ?? '0') ?? 0;
      if (totalTime == 0) continue;

      if (aggregatedStats.containsKey(packageName)) {
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

    // Sort by usage time (descending)
    filteredStats.sort((a, b) {
      final timeA = int.tryParse(a.totalTimeInForeground ?? '0') ?? 0;
      final timeB = int.tryParse(b.totalTimeInForeground ?? '0') ?? 0;
      return timeB.compareTo(timeA);
    });

    // Load app info for top apps
    await _loadAppIcons(filteredStats.take(15).toList());

    return filteredStats;
  }

  Future<void> _loadAppIcons(List<UsageInfo> usageList) async {
    final packagesToFetch = usageList
        .map((usage) => usage.packageName ?? '')
        .where(
          (packageName) =>
              packageName.isNotEmpty && !_appInfoCache.containsKey(packageName),
        )
        .toSet();

    for (final packageName in packagesToFetch) {
      try {
        final app = await InstalledApps.getAppInfo(packageName);
        if (app != null) {
          _appInfoCache[packageName] = app;
        }
      } catch (e) {
        // Silent fail - we'll use default icon
        print('Error loading app info for $packageName: $e');
      }
    }
  }

  Duration _getTimeFrameDuration(String timeFrame) {
    switch (timeFrame) {
      case 'Week':
        return const Duration(days: 7);
      case 'Month':
        return const Duration(days: 30);
      case 'Day':
      default:
        return const Duration(days: 1);
    }
  }

  int _calculateTotalUsageTime(List<UsageInfo> usageStats) {
    return usageStats.fold(0, (total, usage) {
      return total + (int.tryParse(usage.totalTimeInForeground ?? '0') ?? 0);
    });
  }

  Map<String, int> _calculateCategoryBreakdown(List<UsageInfo> usageStats) {
    final Map<String, int> categoryTimes = {};

    for (final usage in usageStats) {
      final category = _getAppCategory(usage.packageName ?? '');
      final time = int.tryParse(usage.totalTimeInForeground ?? '0') ?? 0;
      categoryTimes[category] = (categoryTimes[category] ?? 0) + time;
    }

    return categoryTimes;
  }

  String _getAppCategory(String packageName) {
    if (_appCategories.containsKey(packageName)) {
      return _appCategories[packageName]!;
    }

    final appName = getAppNameFromPackage(
      packageName,
      _appNameCache,
    ).toLowerCase();

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

  // Public getters for UI
  AppInfo? getAppInfo(String packageName) => _appInfoCache[packageName];
  bool hasAppInfo(String packageName) => _appInfoCache.containsKey(packageName);

  // Get app category for UI
  String getAppCategory(String packageName) => _getAppCategory(packageName);
}

// Helper function for app name resolution
String getAppNameFromPackage(String packageName, Map<String, String> cache) {
  if (packageName.isEmpty) return 'Unknown App';

  // Check cache first
  if (cache.containsKey(packageName)) {
    return cache[packageName]!;
  }

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
  final knownApps = {
    'com.google.android.youtube': 'YouTube',
    'com.instagram.android': 'Instagram',
    'com.facebook.katana': 'Facebook',
    'com.whatsapp': 'WhatsApp',
    'com.netflix.mediaclient': 'Netflix',
    'com.spotify.music': 'Spotify',
    'com.mobile.legends': 'Mobile Legends',
    'com.pubg.imobile': 'BGMI',
  };

  if (knownApps.containsKey(packageName)) {
    name = knownApps[packageName]!;
  }

  name = name.isEmpty ? 'Unknown App' : name;

  // Cache the result
  cache[packageName] = name;
  return name;
}

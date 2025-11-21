// features/usage/bloc/usage_state.dart
part of 'usage_bloc.dart';

enum UsageStatus { initial, loading, permissionChecked, success, error }

class UsageState extends Equatable {
  final UsageStatus status;
  final List<UsageInfo> usageStats;
  final bool hasPermission;
  final String selectedTimeFrame;
  final String? error;
  final int totalUsageTime;
  final Map<String, int> categoryBreakdown;
  final Map<String, dynamic> appInfoCache;

  const UsageState({
    this.status = UsageStatus.initial,
    this.usageStats = const [],
    this.hasPermission = false,
    this.selectedTimeFrame = 'Day',
    this.error,
    this.totalUsageTime = 0,
    this.categoryBreakdown = const {},
    this.appInfoCache = const {},
  });

  @override
  List<Object?> get props => [
    status,
    usageStats,
    hasPermission,
    selectedTimeFrame,
    error,
    totalUsageTime,
    categoryBreakdown,
    appInfoCache,
  ];

  UsageState copyWith({
    UsageStatus? status,
    List<UsageInfo>? usageStats,
    bool? hasPermission,
    String? selectedTimeFrame,
    String? error,
    int? totalUsageTime,
    Map<String, int>? categoryBreakdown,
    Map<String, dynamic>? appInfoCache,
  }) {
    return UsageState(
      status: status ?? this.status,
      usageStats: usageStats ?? this.usageStats,
      hasPermission: hasPermission ?? this.hasPermission,
      selectedTimeFrame: selectedTimeFrame ?? this.selectedTimeFrame,
      error: error ?? this.error,
      totalUsageTime: totalUsageTime ?? this.totalUsageTime,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      appInfoCache: appInfoCache ?? this.appInfoCache,
    );
  }
}

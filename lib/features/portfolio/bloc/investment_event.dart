import 'package:equatable/equatable.dart';

/// Base class for all investment-related events
abstract class InvestmentEvent extends Equatable {
  const InvestmentEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch investment data
/// [showLoading] - if true, shows loading spinner during fetch
/// Use showLoading=true for initial load and manual refresh
/// Use showLoading=false (default) for silent background updates
class FetchInvestments extends InvestmentEvent {
  final bool showLoading;

  const FetchInvestments({this.showLoading = false});

  @override
  List<Object> get props => [showLoading];
}

/// Event for background real-time updates
/// This event updates data without showing loading indicators
/// Automatically triggered every 30 seconds when real-time updates are active
class UpdateInvestmentsRealtime extends InvestmentEvent {}

/// Event to start automatic real-time updates
/// Sets up a timer that triggers UpdateInvestmentsRealtime every 30 seconds
class StartRealTimeUpdates extends InvestmentEvent {}

/// Event to stop automatic real-time updates
/// Cancels the timer and stops background data fetching
class StopRealTimeUpdates extends InvestmentEvent {}

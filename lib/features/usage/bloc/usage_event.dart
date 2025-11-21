// features/usage/bloc/usage_event.dart
part of 'usage_bloc.dart';

abstract class UsageEvent extends Equatable {
  const UsageEvent();

  @override
  List<Object> get props => [];
}

class UsagePermissionChecked extends UsageEvent {
  const UsagePermissionChecked();
}

class UsagePermissionRequested extends UsageEvent {
  const UsagePermissionRequested();
}

class UsageStatsFetched extends UsageEvent {
  const UsageStatsFetched();
}

class UsageTimeFrameChanged extends UsageEvent {
  final String timeFrame;

  const UsageTimeFrameChanged(this.timeFrame);

  @override
  List<Object> get props => [timeFrame];
}

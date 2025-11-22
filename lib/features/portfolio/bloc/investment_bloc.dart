import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ravera/features/portfolio/bloc/investment_event.dart';
import 'package:ravera/features/portfolio/models/crypto_investment.dart';
import 'package:ravera/features/portfolio/service/coin_dcx_repository.dart';

part 'investment_state.dart';

class InvestmentBloc extends Bloc<InvestmentEvent, InvestmentState> {
  final CoinDCXRepository repository;
  Timer? _timer;

  InvestmentBloc({required this.repository}) : super(InvestmentInitial()) {
    on<FetchInvestments>(_onFetchInvestments);
    on<UpdateInvestmentsRealtime>(_onUpdateInvestmentsRealtime);
    on<StartRealTimeUpdates>(_onStartRealTimeUpdates);
    on<StopRealTimeUpdates>(_onStopRealTimeUpdates);
  }

  Future<void> _onFetchInvestments(
    FetchInvestments event,
    Emitter<InvestmentState> emit,
  ) async {
    // Only show loading on initial fetch or when explicitly requested
    if (state is! InvestmentLoaded || event.showLoading) {
      emit(InvestmentLoading());
    }

    try {
      final investments = await repository.fetchCryptoData();
      final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
      emit(InvestmentLoaded(investments: investments, lastUpdated: timestamp));
    } catch (e) {
      emit(InvestmentError(message: 'Failed to fetch investments: $e'));
    }
  }

  Future<void> _onUpdateInvestmentsRealtime(
    UpdateInvestmentsRealtime event,
    Emitter<InvestmentState> emit,
  ) async {
    // Only update if we already have data loaded
    if (state is! InvestmentLoaded) return;

    try {
      final investments = await repository.fetchCryptoData();
      final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());

      // Emit updated state without showing loading spinner
      emit(InvestmentLoaded(investments: investments, lastUpdated: timestamp));
    } catch (e) {
      // Silently fail for background updates to avoid disrupting UI
     
      // Keep the current state, just update timestamp to show attempt
      if (state is InvestmentLoaded) {
        final currentState = state as InvestmentLoaded;
        emit(
          currentState.copyWith(
            lastUpdated:
                'Update failed at ${DateFormat('HH:mm:ss').format(DateTime.now())}',
          ),
        );
      }
    }
  }

  void _onStartRealTimeUpdates(
    StartRealTimeUpdates event,
    Emitter<InvestmentState> emit,
  ) {
    _timer?.cancel();

    // Update every 30 seconds in the background
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      add(UpdateInvestmentsRealtime());
    });
  }

  void _onStopRealTimeUpdates(
    StopRealTimeUpdates event,
    Emitter<InvestmentState> emit,
  ) {
    _timer?.cancel();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

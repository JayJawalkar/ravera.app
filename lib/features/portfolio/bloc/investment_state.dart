part of 'investment_bloc.dart';

abstract class InvestmentState extends Equatable {
  const InvestmentState();

  @override
  List<Object> get props => [];
}

class InvestmentInitial extends InvestmentState {}

class InvestmentLoading extends InvestmentState {}

class InvestmentLoaded extends InvestmentState {
  final List<CryptoInvestment> investments;
  final String lastUpdated;

  const InvestmentLoaded({required this.investments, this.lastUpdated = ''});

  @override
  List<Object> get props => [investments, lastUpdated];

  InvestmentLoaded copyWith({
    List<CryptoInvestment>? investments,
    String? lastUpdated,
  }) {
    return InvestmentLoaded(
      investments: investments ?? this.investments,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class InvestmentError extends InvestmentState {
  final String message;

  const InvestmentError({required this.message});

  @override
  List<Object> get props => [message];
}

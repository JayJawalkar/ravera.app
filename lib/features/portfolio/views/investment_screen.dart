import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ravera/features/portfolio/bloc/investment_event.dart';
import 'package:ravera/features/portfolio/service/coin_dcx_repository.dart';
import 'package:ravera/features/portfolio/widgets/bitcoin_chart_widget.dart';
import 'package:ravera/features/portfolio/widgets/investment_wave_painter.dart';
import 'package:ravera/features/portfolio/bloc/investment_bloc.dart';
import 'package:ravera/features/portfolio/models/crypto_investment.dart';

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  List<Map<String, dynamic>> _bitcoinHistoricalData = [];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _loadBitcoinHistoricalData();
  }

  Future<void> _loadBitcoinHistoricalData() async {
    try {
      final repository = CoinDCXRepository();
      final data = await repository.fetchBitcoinHistoricalData();
      print(data);
      setState(() {
        _bitcoinHistoricalData = data;
      });
    } catch (e) {
      print('Failed to load Bitcoin historical data: $e');
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InvestmentBloc(repository: CoinDCXRepository())
        ..add(
          const FetchInvestments(showLoading: true),
        ) // Initial load with spinner
        ..add(StartRealTimeUpdates()), // Start background updates
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

                  // Portfolio Value
                  _buildPortfolioValue(),

                  // Performance Chart
                  _buildPerformanceChart(),

                  // Investment List
                  _buildInvestmentList(),
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
        return CustomPaint(
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
          painter: InvestmentsWavePainter(_waveController.value),
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
            'Investments',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
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
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BlocBuilder<InvestmentBloc, InvestmentState>(
                  builder: (context, state) {
                    // Show loading indicator on refresh button during manual refresh
                    final isManualRefresh = state is InvestmentLoading;

                    return IconButton(
                      icon: isManualRefresh
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.refresh, size: 20),
                      onPressed: isManualRefresh
                          ? null
                          : () {
                              // Manual refresh with loading indicator
                              context.read<InvestmentBloc>().add(
                                const FetchInvestments(showLoading: true),
                              );
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioValue() {
    return BlocBuilder<InvestmentBloc, InvestmentState>(
      builder: (context, state) {
        double portfolioValue = 24850.25;
        double portfolioChange = 12.4;
        double changeAmount = 2740.50;

        if (state is InvestmentLoaded) {
          portfolioValue = state.investments.fold(
            0,
            (sum, investment) => sum + investment.value,
          );
          // Calculate weighted average change
          final totalValue = portfolioValue;
          portfolioChange = state.investments.fold(0, (sum, investment) {
            final weight = investment.value / totalValue;
            return sum + (investment.changePercent * weight);
          });
          changeAmount = portfolioValue * (portfolioChange / 100);
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(
              state is InvestmentLoaded ? state.lastUpdated : 'loading',
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Text(
                  'Portfolio Value',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${portfolioValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      portfolioChange >= 0
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: portfolioChange >= 0
                          ? Colors.green[600]
                          : Colors.red[600],
                      size: 20,
                    ),
                    Text(
                      '${portfolioChange >= 0 ? '+' : ''}${portfolioChange.toStringAsFixed(2)}% (\$${changeAmount.toStringAsFixed(2)})',
                      style: TextStyle(
                        color: portfolioChange >= 0
                            ? Colors.green[600]
                            : Colors.red[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (state is InvestmentLoaded &&
                    state.lastUpdated.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.black.withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Updated: ${state.lastUpdated}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bitcoin Performance (7 Days)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Icon(Icons.auto_graph, color: Colors.orange, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _bitcoinHistoricalData.isNotEmpty
                ? BitcoinChartWidget(
                    historicalData: _bitcoinHistoricalData,
                    chartColor: Colors.orange,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(
                          'Loading Bitcoin data...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<InvestmentBloc, InvestmentState>(
            builder: (context, state) {
              if (state is InvestmentLoaded) {
                final bitcoin = state.investments.firstWhere(
                  (investment) => investment.symbol == 'BTC',
                  orElse: () => CryptoInvestment(
                    name: 'Bitcoin',
                    symbol: 'BTC',
                    value: 0,
                    changePercent: 0,
                    quantity: 0,
                    currentPrice: 0,
                  ),
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current: \$${bitcoin.currentPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      bitcoin.formattedChange,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: bitcoin.isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentList() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Crypto Investments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<InvestmentBloc, InvestmentState>(
                builder: (context, state) {
                  if (state is InvestmentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is InvestmentError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<InvestmentBloc>().add(
                                const FetchInvestments(showLoading: true),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is InvestmentLoaded) {
                    return ListView.builder(
                      itemCount: state.investments.length,
                      itemBuilder: (context, index) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildInvestmentItem(
                            state.investments[index],
                            key: ValueKey(
                              '${state.investments[index].symbol}_${state.lastUpdated}',
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentItem(CryptoInvestment investment, {Key? key}) {
    final color = _getCryptoColor(investment.symbol);

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                investment.symbol.substring(0, 1),
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  investment.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  investment.symbol,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                investment.formattedValue,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                investment.formattedChange,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: investment.isPositive
                      ? Colors.green[600]
                      : Colors.red[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCryptoColor(String symbol) {
    switch (symbol) {
      case 'BTC':
        return Colors.orange;
      case 'ETH':
        return Colors.blue;
      case 'USDT':
        return Colors.green;
      case 'BNB':
        return Colors.yellow;
      case 'ADA':
        return Colors.blueAccent;
      case 'XRP':
        return Colors.black;
      case 'SOL':
        return Colors.purple;
      case 'DOT':
        return Colors.pink;
      case 'DOGE':
        return Colors.amber;
      case 'MATIC':
        return Colors.purpleAccent;
      default:
        return Colors.grey;
    }
  }
}

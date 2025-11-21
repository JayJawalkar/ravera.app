// Update coin_dcx_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ravera/features/portfolio/models/crypto_investment.dart';

class CoinDCXRepository {
  static const String _baseUrl = 'https://api.coindcx.com';
  static const Map<String, String> _cryptoMapping = {
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'USDT': 'Tether',
    'BNB': 'Binance Coin',
    'ADA': 'Cardano',
    'XRP': 'Ripple',
    'SOL': 'Solana',
    'DOT': 'Polkadot',
    'DOGE': 'Dogecoin',
    'MATIC': 'Polygon',
  };

  Future<List<CryptoInvestment>> fetchCryptoData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exchange/ticker'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Ravera/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return _parseCryptoData(data);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockData();
    }
  }

  // Add this new method to fetch Bitcoin historical data
  Future<List<Map<String, dynamic>>> fetchBitcoinHistoricalData() async {
    try {
      // Using CoinGecko API for historical data
      final response = await http.get(
        Uri.parse(
          'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=7&interval=daily',
        ),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Ravera/1.0',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> prices = data['prices'];

        // Take only the last 7 data points to avoid too many points
        final recentPrices = prices.length > 7
            ? prices.sublist(prices.length - 7)
            : prices;

        return recentPrices.map<Map<String, dynamic>>((price) {
          final timestamp = price[0] as int;
          final priceValue = price[1] as double;
          return {
            'timestamp': timestamp,
            'price': priceValue,
            'date': DateTime.fromMillisecondsSinceEpoch(timestamp),
          };
        }).toList();
      } else {
        throw Exception(
          'Failed to load historical data: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching Bitcoin historical data: $e');
      // Fallback to mock historical data with proper current dates
      return _getMockHistoricalData();
    }
  }

  List<Map<String, dynamic>> _getMockHistoricalData() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> mockData = [];
    double basePrice = 85000.0;

    // Generate 7 days of data including today
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // Simulate realistic price variation
      final variation = (i % 2 == 0) ? 1500.0 : -800.0;
      final price = basePrice + variation + (i * 500);

      mockData.add({
        'timestamp': date.millisecondsSinceEpoch,
        'price': price,
        'date': date,
      });
    }

    return mockData;
  }

  List<CryptoInvestment> _parseCryptoData(List<dynamic> data) {
    final List<CryptoInvestment> investments = [];
    final usdtPairs = data.where((item) {
      final market = item['market']?.toString() ?? '';
      return market.endsWith('USDT') &&
          _cryptoMapping.keys.any((crypto) => market.startsWith(crypto));
    }).toList();

    // Take top 5 cryptocurrencies
    final selectedPairs = usdtPairs.take(5).toList();

    for (int i = 0; i < selectedPairs.length; i++) {
      final crypto = selectedPairs[i];
      final market = crypto['market']?.toString() ?? '';
      final symbol = market.replaceAll('USDT', '');
      final lastPrice =
          double.tryParse(crypto['last_price']?.toString() ?? '0') ?? 0;
      final change24h =
          double.tryParse(crypto['change_24_hour']?.toString() ?? '0') ?? 0;

      // Mock quantity for demo purposes
      final quantity = _getMockQuantity(symbol);
      final value = lastPrice * quantity;

      investments.add(
        CryptoInvestment(
          name: _cryptoMapping[symbol] ?? symbol,
          symbol: symbol,
          value: value,
          changePercent: change24h,
          quantity: quantity,
          currentPrice: lastPrice,
        ),
      );
    }

    return investments;
  }

  double _getMockQuantity(String symbol) {
    final quantities = {
      'BTC': 0.5,
      'ETH': 3.2,
      'USDT': 1500.0,
      'BNB': 8.5,
      'ADA': 2000.0,
      'XRP': 3500.0,
      'SOL': 15.0,
      'DOT': 120.0,
      'DOGE': 10000.0,
      'MATIC': 800.0,
    };
    return quantities[symbol] ?? 100.0;
  }

  List<CryptoInvestment> _getMockData() {
    return [
      CryptoInvestment(
        name: 'Bitcoin',
        symbol: 'BTC',
        value: 8420.50,
        changePercent: 12.5,
        quantity: 0.5,
        currentPrice: 16841.0,
      ),
      CryptoInvestment(
        name: 'Ethereum',
        symbol: 'ETH',
        value: 6150.75,
        changePercent: 8.2,
        quantity: 3.2,
        currentPrice: 1922.11,
      ),
      CryptoInvestment(
        name: 'Cardano',
        symbol: 'ADA',
        value: 5280.25,
        changePercent: 15.1,
        quantity: 2000.0,
        currentPrice: 2.64,
      ),
      CryptoInvestment(
        name: 'Solana',
        symbol: 'SOL',
        value: 4250.80,
        changePercent: 5.8,
        quantity: 15.0,
        currentPrice: 283.39,
      ),
      CryptoInvestment(
        name: 'Polygon',
        symbol: 'MATIC',
        value: 750.30,
        changePercent: 3.2,
        quantity: 800.0,
        currentPrice: 0.94,
      ),
    ];
  }
}

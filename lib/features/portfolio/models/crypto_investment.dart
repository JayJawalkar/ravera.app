class CryptoInvestment {
  final String name;
  final String symbol;
  final double value;
  final double changePercent;
  final double quantity;
  final double currentPrice;
  final String currency;

  const CryptoInvestment({
    required this.name,
    required this.symbol,
    required this.value,
    required this.changePercent,
    required this.quantity,
    required this.currentPrice,
    this.currency = 'USD',
  });

  String get formattedValue => '\$${value.toStringAsFixed(2)}';
  String get formattedChange => '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
  bool get isPositive => changePercent >= 0;

  CryptoInvestment copyWith({
    String? name,
    String? symbol,
    double? value,
    double? changePercent,
    double? quantity,
    double? currentPrice,
    String? currency,
  }) {
    return CryptoInvestment(
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      value: value ?? this.value,
      changePercent: changePercent ?? this.changePercent,
      quantity: quantity ?? this.quantity,
      currentPrice: currentPrice ?? this.currentPrice,
      currency: currency ?? this.currency,
    );
  }
}
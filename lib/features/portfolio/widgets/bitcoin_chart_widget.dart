import 'package:flutter/material.dart';

class BitcoinChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> historicalData;
  final Color chartColor;

  const BitcoinChartWidget({
    super.key,
    required this.historicalData,
    this.chartColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    if (historicalData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.4)),
        ),
      );
    }

    // Sort data by timestamp to ensure chronological order
    final sortedData = List<Map<String, dynamic>>.from(
      historicalData,
    )..sort((a, b) => (a['timestamp'] as Comparable).compareTo(b['timestamp']));

    final prices = sortedData.map((data) => data['price'] as double).toList();

    if (prices.isEmpty) {
      return Center(
        child: Text(
          'No price data',
          style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.4)),
        ),
      );
    }

    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    // Generate date labels for the x-axis
    final dateLabels = _generateDateLabels(sortedData);

    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _BitcoinChartPainter(
                historicalData: sortedData,
                minPrice: minPrice,
                maxPrice: maxPrice,
                priceRange: priceRange,
                chartColor: chartColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildXAxisLabels(dateLabels),
        ],
      ),
    );
  }

  List<String> _generateDateLabels(List<Map<String, dynamic>> data) {
    if (data.length < 3) {
      return ['Start', 'End'];
    }

    // Take first, middle, and last points for labels
    final firstDate = data.first['date'] as DateTime;
    final middleDate = data[data.length ~/ 2]['date'] as DateTime;
    final lastDate = data.last['date'] as DateTime;

    return [
      _formatDate(firstDate),
      _formatDate(middleDate),
      _formatDate(lastDate),
    ];
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  Widget _buildXAxisLabels(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((label) {
        return Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.black.withOpacity(0.6)),
        );
      }).toList(),
    );
  }
}

class _BitcoinChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> historicalData;
  final double minPrice;
  final double maxPrice;
  final double priceRange;
  final Color chartColor;

  _BitcoinChartPainter({
    required this.historicalData,
    required this.minPrice,
    required this.maxPrice,
    required this.priceRange,
    required this.chartColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (historicalData.length < 2) {
      _drawNoDataMessage(canvas, size);
      return;
    }

    final paint = Paint()
      ..color = chartColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = chartColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = chartColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < historicalData.length; i++) {
      final point = historicalData[i];
      final x = (i / (historicalData.length - 1)) * size.width;
      final price = point['price'] as double;
      final y = size.height - ((price - minPrice) / priceRange * size.height);

      points.add(Offset(x, y));
    }

    // Start the path
    path.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, points.first.dy);

    // Draw smooth curve through points
    for (int i = 1; i < points.length; i++) {
      final p1 = points[i];

      // Simple line for now - you can enhance with cubic bezier for smoother curves
      path.lineTo(p1.dx, p1.dy);
      fillPath.lineTo(p1.dx, p1.dy);
    }

    // Close the fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Draw filled area first
    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw data points (only first, last, and significant points)
    final pointsToDraw = <int>[0]; // First point
    if (historicalData.length > 3) {
      pointsToDraw.add(historicalData.length ~/ 2); // Middle point
    }
    pointsToDraw.add(historicalData.length - 1); // Last point

    for (final index in pointsToDraw) {
      final point = points[index];
      canvas.drawCircle(point, 3.0, dotPaint);

      // Draw a white border around the dot
      canvas.drawCircle(
        point,
        3.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Draw current price label for the last point
    if (points.isNotEmpty) {
      _drawPriceLabel(
        canvas,
        points.last,
        historicalData.last['price'] as double,
        size,
      );
    }
  }

  void _drawPriceLabel(Canvas canvas, Offset point, double price, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '\$${price.toStringAsFixed(0)}',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Position the label above the point
    final textOffset = Offset(point.dx - textPainter.width / 2, point.dy - 20);

    // Draw background
    final backgroundRect = Rect.fromPoints(
      textOffset,
      textOffset.translate(textPainter.width, textPainter.height),
    ).inflate(4);

    canvas.drawRect(
      backgroundRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    canvas.drawRect(
      backgroundRect,
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    textPainter.paint(canvas, textOffset);
  }

  void _drawNoDataMessage(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Insufficient data for chart',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

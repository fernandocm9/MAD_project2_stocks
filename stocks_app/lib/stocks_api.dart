import 'dart:convert';
import 'package:http/http.dart' as http;
import 'search.dart';

class StockResponse {
  final String stockSymbol;
  final String stockName;
  final double currentPrice;
  final List<chartData> chartInfo;

  StockResponse({
    required this.stockSymbol,
    required this.stockName,
    required this.currentPrice,
    required this.chartInfo,
  });
  @override
  String toString() {
    return 'StockResponse(stockSymbol: $stockSymbol, stockName: $stockName, currentPrice: $currentPrice, chartInfo: $chartInfo)';
  }
}

class chartData {
  final String date; 
  final double currentPrice; 
  chartData({
    required this.date, 
    required this.currentPrice,
  });
  @override
  String toString() {
    return 'chartData(date: $date, currentPrice: $currentPrice)';
  }
}

class Stocks_Api {
  static fetchStockInformation(String searchItem) async {
    StockResponse currentStock;
    dynamic profileData; 
    String API_KEY = "d04j5l9r01qspgm3bhl0d04j5l9r01qspgm3bhlg";
    String AV_KEY = "51AMZTLKTGKNY08K";
    try {
      final profile = await http.get(
        Uri.parse('https://finnhub.io/api/v1/stock/profile2?symbol=$searchItem&token=$API_KEY'),
      );
      if (profile.statusCode == 200) {
        profileData = json.decode(profile.body);
      }

      // From 1 month ago - Today
      final today = DateTime.now();
      final endDate = DateTime(today.year, today.month - 1, today.day - 1); 

      final timeSeries = await http.get(
        Uri.parse('https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$searchItem&outputsize=full&apikey=$AV_KEY'),
      );
      if (timeSeries.statusCode == 200) {
        final timeData = json.decode(timeSeries.body);
        List<chartData> currentChartInfo = [];
        final dailyInfo = timeData['Time Series (Daily)'] as Map<String, dynamic>; // Written as [date] : [open, high, low...]

        for (final day in dailyInfo.entries) {
          final date = DateTime.parse(day.key);
          if (date.isBefore(endDate)) {
            break;
          } else {
            final dayString = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
            currentChartInfo.add(chartData(
              date: dayString,
              currentPrice: double.parse(day.value['4. close'])
            ));
          }
        }
        final price = currentChartInfo[0].currentPrice;
        currentChartInfo = currentChartInfo.reversed.toList();

        currentStock = StockResponse(
          stockSymbol: searchItem, 
          stockName: profileData['name'],
          currentPrice: price, 
          chartInfo: currentChartInfo,
        );

        return currentStock; 
      } else {
        throw Exception("Error pulling data with status code ${timeSeries.statusCode}");
      }

    } catch (error) {
      throw Exception("Error loading stock information: $error");
    }
  }
}
/*{Meta Data: {
          1. Information: Daily Prices (open, high, low, close) and Volumes, 
          2. Symbol: KO, 
          3. Last Refreshed: 2025-04-25, 
          4. Output Size: Full size, 
          5. Time Zone: US/Eastern}, 
          Time Series (Daily): {
            2025-04-25: {1. open: 72.6500, 2. high: 72.9200, 3. low: 71.1250, 4. close: 71.9100, 5. volume: 16287954}, 
            2025-04-24: {1. open: 73.0200, 2. high: 73.4250, 3. low: 72.3000, 4. close: 72.5200, 5. volume: 16893861}, 
            2025-04-23: {1. open: 73.2900, 2. high: 73.9500, 3. low: 72.3800, 4. close: 73.3000, 5. volume: 16353927}, 
            2025-04-22: {1. open: 73.0000, 2. high: 74.3800, 3. low: 72.9200, 4. close: 73.9000, 5. volume: 15613518}, 
            2025-04-21: {1. open: 73.3800, 2. high: 73.4723, 3. low: 71.8200, 4. close: 72.7700, 5. volume: 16037190}, 
            2025-04-17: {1. open: 71.9000, 2. high: 73.4250, 3. low: 71.7200, 4. close: 73.0000, 5. volume: 20754495},
            2025-04-16: {1. open: 72.3600, 2. high: 72.6650, 3. low: 71.3850, 4. close: 71.6800, 5. volume: 15276216}, 
            2025-04-15: {1. open: 72.6200, 2. high: 72.6300, 3. low: 71.7250, 4. clo ...*/
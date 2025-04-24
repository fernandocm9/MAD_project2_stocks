import 'dart:convert';
import 'package:http/http.dart' as http;
import 'search.dart';

class StockResponse {
  final String stockSymbol;
  final String stockName;
  final double currentPrice;
  //final List<double> monthPrices;

  StockResponse({
    required this.stockSymbol,
    required this.stockName,
    required this.currentPrice,
    //required this.monthPrices,
  });
}

class Stocks_Api {
  static fetchStockInformation(String searchItem) async {
    StockResponse currentStock;
    dynamic profileData; 
    dynamic quoteData;
    try {
      final profile = await http.get(
        Uri.parse('https://finnhub.io/api/v1/stock/profile2?symbol=$searchItem&token=d04j5l9r01qspgm3bhl0d04j5l9r01qspgm3bhlg'),
      );
      if (profile.statusCode == 200) {
        profileData = json.decode(profile.body);
        /*List<Question> questions = (data['results'] as List)
            .map((questionData) => Question.fromJson(questionData))
            .toList();*/
        //print('Current Price: ${data['c']}');
        //result = data['name'];
      }

      final quote = await http.get(
        Uri.parse('https://finnhub.io/api/v1/quote?symbol=$searchItem&token=d04j5l9r01qspgm3bhl0d04j5l9r01qspgm3bhlg'),
      );
      if (quote.statusCode == 200) {
        quoteData = json.decode(quote.body);
      }

      return currentStock = StockResponse(
        stockSymbol: searchItem, 
        stockName: profileData['name'], 
        currentPrice: quoteData['c'], 
        //monthPrices: monthPrices
      );
    } catch (error) {
      print("Error loading stock information: $error");
      return;
    }
  }
}

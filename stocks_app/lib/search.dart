import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_gate.dart';
import 'stocks_api.dart';
import 'package:fl_chart/fl_chart.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String companyName = "";
  String stockSymbol = "Symbol";
  double displayPrice = 0.0;
  List<chartData> chartPrices = [];
  
  _search(String searchItem) async {
    searchItem = searchItem.trim();
    if (searchItem.isEmpty) {
      print("No search item entered.");
      return;
    }
    try {
      StockResponse result = await Stocks_Api.fetchStockInformation(searchItem);
      setState(() {
        stockSymbol = result.stockSymbol;
        companyName = result.stockName; 
        displayPrice = result.currentPrice;
        chartPrices = result.chartInfo;
      });
    } catch (error) {
      print("_search() error: $error");
    }
  }

  _watchAlert() {
    print("Added " + stockSymbol + " to watchlist!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(), 
                hintText: 'Stock symbol'
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _search(_searchController.text),
              child: Text("Confirm"),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.black,
                  height: 70.0,
                  width: 140.0,
                  child: Center(
                    child: Text(
                      stockSymbol,
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
                SizedBox(width: 80),
                Container(
                  color: Colors.black,
                  height: 70.0,
                  width: 140.0,
                  child: Center(
                    child: Text(
                      '$displayPrice',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              companyName, 
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 15),
            if (chartPrices.isNotEmpty)
              Container(
                height: 350,
                width: 350,
                padding: EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: chartPrices.map((point) {
                          int xIndex = chartPrices.toList().indexOf(point);
                          return FlSpot(xIndex.toDouble(), point.currentPrice);
                        }).toList(),
                        barWidth: 2, //line weight
                        belowBarData: BarAreaData(show: false),
                        dotData: FlDotData(show: false),
                      ),
                    ],
                    minY: chartPrices.map((data) => data.currentPrice).reduce((curr, next) => curr < next ? curr : next) - 1,
                    maxY: chartPrices.map((data) => data.currentPrice).reduce((curr, next) => curr > next ? curr : next) + 1,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          getTitlesWidget: (value, _) {
                            int index = value.toInt();
                            if (index >= 0 && index < chartPrices.length) {
                              return Text(chartPrices.toList()[index].date);
                            }
                            return Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, _) => Text(
                            value.toStringAsFixed(0),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    gridData: FlGridData(show: true),
                  ),
                ),
              )
            else
              SizedBox(
                height: 350, 
                width: 350, 
                child: Text("No data searched yet.")
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _watchAlert(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
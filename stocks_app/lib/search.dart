import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_gate.dart';
import 'stocks_api.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String companyName = "";
  String stockSymbol = "Symbol";
  double currentPrice = 0.0;

  _search(String searchItem) async {
    searchItem = searchItem.trim();
    if (searchItem.isEmpty) {
      print("No search item entered.");
      return;
    }
    try {
      StockResponse result = await Stocks_Api.fetchStockInformation(searchItem);
      /*if (result.isEmpty || result == null) {
        print("This stock symbol could not be found.");
        return;
      }*/
      setState(() {
        stockSymbol = result.stockSymbol;
        companyName = result.stockName; 
        currentPrice = result.currentPrice;
      });
    } catch (error) {
      print("Error fetching stock data: $error");
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
              child: Text("Confirm")
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
                      '$currentPrice',
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
            Container(
              height: 300,
              width: 300,
              color: Colors.blue,
            ),
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
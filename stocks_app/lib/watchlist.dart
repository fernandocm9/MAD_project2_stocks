import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class StockProfile {
  final String country;
  final String currency;
  final String exchange;
  final String name;
  final String ticker;
  final String logoUrl;
  final String category;

  StockProfile({
    required this.country,
    required this.currency,
    required this.exchange,
    required this.name,
    required this.ticker,
    required this.logoUrl,
    required this.category,
  });

  factory StockProfile.fromJson(Map<String, dynamic> json) {
    return StockProfile(
      country: json['country'] ?? '',
      currency: json['currency'] ?? '',
      exchange: json['exchange'] ?? '',
      name: json['name'] ?? '',
      ticker: json['ticker'] ?? '',
      logoUrl: json['logo'] ?? '',
      category: json['finnhubIndustry'] ?? 'Uncategorized',
    );
  }
}

Future<StockProfile> fetchStockProfile(String symbol) async {
  final response = await http.get(
    Uri.parse('https://finnhub.io/api/v1/stock/profile2?symbol=$symbol&token=cvvvnshr01qud9qkv3hgcvvvnshr01qud9qkv3i0'),
  );

  if (response.statusCode == 200) {
    return StockProfile.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load stock profile');
  }
}

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, List<StockProfile>> categorizedStocks = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await _firestore.collection('watchlists').where('user_id', isEqualTo: user.uid).get();
      final watchlistStocks = snapshot.docs.map((doc) => doc['symbol'] as String).toList();

      List<StockProfile> profiles = [];
      for (String symbol in watchlistStocks) {
        try {
          final profile = await fetchStockProfile(symbol);
          profiles.add(profile);
        } catch (e) {
          print('Failed to fetch profile for $symbol: $e');
        }
      }

      Map<String, List<StockProfile>> categorized = {};
      for (var profile in profiles) {
        categorized.putIfAbsent(profile.category, () => []).add(profile);
      }

      setState(() {
        categorizedStocks = categorized;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading watchlist: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categorizedStocks.isEmpty) {
      return const Center(child: Text('No stocks in your watchlist.'));
    }

    return ListView(
      children: categorizedStocks.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                entry.key,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ...entry.value.map((profile) => ListTile(
                  leading: profile.logoUrl.isNotEmpty
                      ? Image.network(profile.logoUrl, width: 40, height: 40, fit: BoxFit.cover)
                      : const Icon(Icons.business),
                  title: Text(profile.name),
                  subtitle: Text(profile.ticker),
                ))
          ],
        );
      }).toList(),
    );
  }
}

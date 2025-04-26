import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      return const Center(child: Text('No user logged in.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('watchlists').where('user_id', isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading watchlist.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No stocks in your watchlist.'));
        }

        final watchlistStocks = snapshot.data!.docs.map((doc) {
          return doc['symbol'] as String;
        }).toList();

        return ListView.builder(
          itemCount: watchlistStocks.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(watchlistStocks[index]),
            );
          },
        );
      },
    );
  }
}

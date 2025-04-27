import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_gate.dart';
import 'stocks_api.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final user = FirebaseAuth.instance.currentUser;
  List<String> topics = [];
  List<NewsInfo> newsList = [];

  @override
  void initState() {
    super.initState();
    getNews();
  }

  fetchWatchList() async {
    try {
      topics.clear();
       final snapshot = await FirebaseFirestore.instance
        .collection('watchlists')
        .where('user_id', isEqualTo: user!.uid)
        .get();

      for (var doc in snapshot.docs) {
        if (!(topics.contains(doc['companyName']))) {
          String companyName = doc['companyName'];
          topics.add(companyName);
        }
      }
    } catch (error) {
      print("Error fetching watchlist: $error");
    }
  }

  /*Future<List<NewsInfo>>*/ getNews() async {
    await fetchWatchList();
    if (topics.isEmpty) {
      print("Enter watchlist items first.");
      return [];
    }
    List<NewsInfo> results = await Stocks_Api.fetchNewsInformation(topics);
    newsList = results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          final news = newsList[index];
          return Container(
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${news.headline} [${news.author}]'),
                Text('${news.date} ${news.description}'),
              ],
            ),
          );
        },
      )
    );
  }
}

class NewsCard extends StatefulWidget {
  const NewsCard({super.key});
  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            children: <Widget>[
              // Title
              SizedBox(
                child: Text('Title')
              ),
              // Author + Date
              Row(
                children: [
                  Text("AUTHOR"),
                  Text("04/04"),
                ],
              ),
              //Description
              SizedBox(
                child: Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. ')
              ),
            ],
          ), 
        ),
    );
  }
}
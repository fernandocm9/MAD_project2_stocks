import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_gate.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*Text(
              'Welcome, $userEmail!',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),*/
            const Text(
              'search!',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
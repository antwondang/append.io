import 'package:flutter/material.dart';

void main() {
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plaid Portfolio Dashboard',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.teal,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            "Ready to connect to Plaid!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
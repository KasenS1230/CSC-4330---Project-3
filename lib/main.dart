import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GrocerySplitterApp());
}

class GrocerySplitterApp extends StatelessWidget {
  const GrocerySplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Splitter',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
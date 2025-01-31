import 'package:flutter/material.dart';
// import 'package:gate_sentinal/Pages/home.dart';
import 'package:gate_sentinal/Main_pages/welcomepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Welcomepage(),
    );
  }
}


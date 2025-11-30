// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart'; // YENİ IMPOR

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Tracking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF0F1F3),
      ),
      home: const DashboardScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyDietApp());
}

class MyDietApp extends StatefulWidget {
  const MyDietApp({super.key});

  @override
  State<MyDietApp> createState() => _MyDietAppState();
}

class _MyDietAppState extends State<MyDietApp> {
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      return;
    }
    if (!mounted) return;
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2));
      await prefs.setBool('darkMode', value);
    } catch (_) {}
    setState(() {
      darkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF16823A);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyDiet Kids',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAF5),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: seed,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: DashboardScreen(darkMode: darkMode, toggleTheme: _toggleTheme),
    );
  }
}

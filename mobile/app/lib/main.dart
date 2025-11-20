import 'package:app/Home/home.dart';
import 'package:app/login/login.dart';
import 'package:flutter/material.dart';
import 'package:app/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(token: ''),
      }, // temporary loading screen
    );
  }
}

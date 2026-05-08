import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TweeterApp());
}

class TweeterApp extends StatelessWidget {
  const TweeterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tweeter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

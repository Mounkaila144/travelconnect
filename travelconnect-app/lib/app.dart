import 'package:flutter/material.dart';

class TravelConnectApp extends StatelessWidget {
  const TravelConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelConnect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('TravelConnect'),
        ),
      ),
    );
  }
}

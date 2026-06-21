import 'package:flutter/material.dart';

import 'package:gnps/splash_screen.dart';

void main() {
  runApp(const GnpsApp());
}

class GnpsApp extends StatelessWidget {
  const GnpsApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const SplashScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vibez/home.dart';
import 'package:vibez/permission_screen.dart';
import 'package:vibez/splash_screen.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibez',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/permission': (context) => const PermissionScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
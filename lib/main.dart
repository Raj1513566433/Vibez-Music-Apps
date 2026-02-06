import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibez/app.dart';
import 'package:vibez/music_service.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => MusicService(),
      child: const MyApp(),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zpesmuktowfvcmhfzruw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwZXNtdWt0b3dmdmNtaGZ6cnV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1MzI4NjMsImV4cCI6MjA2NzEwODg2M30.CHKMHnLtrEjclIXHNk34NyEd4GPsYkL6rSBSWEdVqpg',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deutsch Lernen – Leicht-Erlernen',
      theme: ThemeData(
        primaryColor: const Color(0xFF3b3ec3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3b3ec3),
          primary: const Color(0xFF3b3ec3),
          secondary: const Color(0xFFf3f2f5),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const WelcomePage(),
    );
  }
}

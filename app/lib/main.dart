import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://wnulzdmcpyzyvtphegev.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndudWx6ZG1jcHl6eXZ0cGhlZ2V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2ODg5ODEsImV4cCI6MjA5MDI2NDk4MX0.SNErS8tHateepqwA0_Sv7q2tDq3GR2MvwWsyFeA4UNg',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

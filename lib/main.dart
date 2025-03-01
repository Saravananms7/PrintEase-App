import 'package:flutter/material.dart';
import 'package:t_store/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ymdppwygkeebxzxvqpmo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InltZHBwd3lna2VlYnh6eHZxcG1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA1MTE1MTEsImV4cCI6MjA1NjA4NzUxMX0.nI-lrQmahfP12s5bxP7aBsOlZVJIfSve2K4pQLhCI3o', // Replace with your actual anon key
  );

  runApp(const App());
}
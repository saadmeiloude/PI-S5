import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://vsdxqgjzttpdabcxwxro.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzZHhxZ2p6dHRwZGFiY3h3eHJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzMjgxODgsImV4cCI6MjA3NzkwNDE4OH0.uOeXsOUNCYFQFKMyZnqQz6t6-flSfWjKiKcoxsZElr8';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}

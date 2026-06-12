import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    // Frictionless start: anonymous session so RLS-scoped data works
    // immediately. Swap for real email/social auth before launch.
    // (Enable "Anonymous sign-ins" under Auth settings in Supabase.)
    final auth = Supabase.instance.client.auth;
    if (auth.currentSession == null) {
      try {
        await auth.signInAnonymously();
      } catch (e) {
        debugPrint('Anonymous sign-in failed: $e');
      }
    }
  }

  runApp(const AppendApp());
}

class AppendApp extends StatelessWidget {
  const AppendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'append.io',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeShell(),
    );
  }
}

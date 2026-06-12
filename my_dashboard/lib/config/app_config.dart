/// Build-time configuration.
///
/// Values come from env.json (git-ignored; copy env.example.json):
///   flutter run --dart-define-from-file=env.json
///
/// These are client-safe values (the Supabase publishable key is designed
/// to ship in apps — RLS protects the data). Real secrets (Plaid keys,
/// service-role key) live only in Supabase function secrets, server-side.
///
/// When these are empty the app runs in demo mode with mock data so the
/// UI is fully explorable before any backend is set up.
class AppConfig {
  AppConfig._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

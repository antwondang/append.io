import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../services/portfolio_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _syncing = false;

  Future<void> _syncNow() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _syncing = true);
    try {
      await PortfolioService.instance.syncFromPlaid();
      messenger.showSnackBar(
        const SnackBar(content: Text('Holdings refreshed.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Sync failed: $e')));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = AppConfig.isSupabaseConfigured;
    final userId =
        isLive ? Supabase.instance.client.auth.currentUser?.id : null;
    final lastUpdated = PortfolioService.instance.lastUpdated;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    isLive ? Icons.cloud_done : Icons.cloud_off,
                    color: isLive ? AppTheme.gain : AppTheme.textSecondary,
                  ),
                  title: const Text(
                    'Backend',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: Text(
                    isLive
                        ? 'Connected to Supabase'
                        : 'Demo mode — no backend configured',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                if (userId != null)
                  ListTile(
                    leading: const Icon(Icons.person_outline,
                        color: AppTheme.textSecondary),
                    title: const Text(
                      'User',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    subtitle: Text(
                      userId,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (lastUpdated != null)
                  ListTile(
                    leading: const Icon(Icons.update,
                        color: AppTheme.textSecondary),
                    title: const Text(
                      'Last refreshed',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    subtitle: Text(
                      lastUpdated.toLocal().toString().split('.').first,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: _syncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync, color: AppTheme.accent),
              title: const Text(
                'Sync holdings now',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: const Text(
                'Re-pull balances and positions from Plaid',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              onTap: _syncing ? null : _syncNow,
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'append.io aggregates all your brokerage and retirement '
                    'accounts in one place. Account data is read-only and '
                    'fetched via Plaid; credentials are never stored in the app.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/account.dart';
import '../services/plaid_service.dart';
import '../services/portfolio_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/account_tile.dart';
import 'account_detail_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool _connecting = false;

  Future<void> _connectAccount() async {
    final portfolio = PortfolioService.instance;
    final messenger = ScaffoldMessenger.of(context);

    if (!portfolio.isLive) {
      messenger.showSnackBar(const SnackBar(
        content: Text(
          'Demo mode — set SUPABASE_URL / SUPABASE_ANON_KEY via --dart-define '
          'to link real accounts through Plaid.',
        ),
      ));
      return;
    }

    setState(() => _connecting = true);
    await PlaidService.instance.connect(
      onLinked: (institution) async {
        await portfolio.load();
        if (mounted) setState(() => _connecting = false);
        messenger.showSnackBar(
          SnackBar(content: Text('$institution linked successfully!')),
        );
      },
      onError: (message) {
        if (mounted) setState(() => _connecting = false);
        messenger.showSnackBar(SnackBar(content: Text(message)));
      },
    );
    // Link UI is now open; re-enable the button so a dismissed flow
    // doesn't leave it stuck.
    if (mounted) setState(() => _connecting = false);
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = PortfolioService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _connecting ? null : _connectAccount,
        icon: _connecting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_link),
        label: const Text('Connect'),
      ),
      body: ListenableBuilder(
        listenable: portfolio,
        builder: (context, _) {
          final byInstitution = <String, List<Account>>{};
          for (final account in portfolio.accounts) {
            byInstitution
                .putIfAbsent(account.institutionName, () => [])
                .add(account);
          }

          return RefreshIndicator(
            onRefresh: portfolio.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final entry in byInstitution.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          formatCurrency(entry.value
                              .fold(0.0, (sum, a) => sum + a.balance)),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        for (final account in entry.value)
                          AccountTile(
                            account: account,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AccountDetailScreen(account: account),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (portfolio.accounts.isEmpty && !portfolio.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        'No accounts yet.\nTap Connect to link one with Plaid.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

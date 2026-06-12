import 'package:flutter/material.dart';

import '../models/holding.dart';
import '../services/portfolio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/account_tile.dart';
import '../widgets/allocation_bar.dart';
import '../widgets/holding_tile.dart';
import '../widgets/net_worth_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolio = PortfolioService.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('append.io'),
        actions: [
          if (!portfolio.isLive)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Chip(
                  label: Text('DEMO', style: TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppTheme.surfaceLight,
                  side: BorderSide.none,
                ),
              ),
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: portfolio,
        builder: (context, _) {
          if (portfolio.isLoading && portfolio.accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (portfolio.error != null && portfolio.accounts.isEmpty) {
            return _ErrorState(
              message: portfolio.error!,
              onRetry: portfolio.load,
            );
          }

          final topHoldings =
              AggregatedHolding.aggregate(portfolio.holdings).take(5).toList();
          final topAccounts = portfolio.accounts.take(4).toList();

          return RefreshIndicator(
            onRefresh: portfolio.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                NetWorthCard(
                  totalValue: portfolio.totalValue,
                  totalGain: portfolio.totalGain,
                  totalGainFraction: portfolio.totalGainFraction,
                  accountCount: portfolio.accounts.length,
                ),
                const SizedBox(height: 16),
                if (portfolio.accounts.isNotEmpty) ...[
                  const _SectionHeader('Allocation'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AllocationBar(
                        allocation: portfolio.allocationByCategory,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionHeader('Accounts'),
                  Card(
                    child: Column(
                      children: [
                        for (final account in topAccounts)
                          AccountTile(account: account),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionHeader('Top holdings'),
                  Card(
                    child: Column(
                      children: [
                        for (final holding in topHoldings)
                          HoldingTile(holding: holding),
                      ],
                    ),
                  ),
                ] else
                  const _EmptyState(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: const [
            Icon(Icons.account_balance, size: 48, color: AppTheme.textSecondary),
            SizedBox(height: 12),
            Text(
              'No accounts linked yet',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Head to the Accounts tab and connect your first brokerage or retirement account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

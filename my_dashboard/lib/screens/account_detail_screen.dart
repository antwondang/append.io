import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/holding.dart';
import '../services/portfolio_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/holding_tile.dart';

class AccountDetailScreen extends StatelessWidget {
  final Account account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final holdings = AggregatedHolding.aggregate(
      PortfolioService.instance.holdingsForAccount(account.id),
    );

    return Scaffold(
      appBar: AppBar(title: Text(account.institutionName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatCurrency(account.balance),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      account.category,
                      if (account.mask != null) '••${account.mask}',
                    ].join(' · '),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (holdings.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Holdings',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  for (final holding in holdings) HoldingTile(holding: holding),
                ],
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'No holdings reported for this account.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

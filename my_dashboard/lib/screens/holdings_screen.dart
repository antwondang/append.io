import 'package:flutter/material.dart';

import '../models/holding.dart';
import '../services/portfolio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/holding_tile.dart';

class HoldingsScreen extends StatefulWidget {
  const HoldingsScreen({super.key});

  @override
  State<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final portfolio = PortfolioService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Holdings')),
      body: ListenableBuilder(
        listenable: portfolio,
        builder: (context, _) {
          var holdings = AggregatedHolding.aggregate(portfolio.holdings);
          if (_query.isNotEmpty) {
            final q = _query.toLowerCase();
            holdings = holdings
                .where((h) =>
                    h.symbol.toLowerCase().contains(q) ||
                    h.name.toLowerCase().contains(q))
                .toList();
          }

          return RefreshIndicator(
            onRefresh: portfolio.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search ticker or name',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    prefixIcon:
                        const Icon(Icons.search, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (holdings.isNotEmpty)
                  Card(
                    child: Column(
                      children: [
                        for (final holding in holdings)
                          HoldingTile(holding: holding),
                      ],
                    ),
                  )
                else if (!portfolio.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        'No holdings found.',
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

import 'package:flutter/material.dart';

import '../models/holding.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class HoldingTile extends StatelessWidget {
  final AggregatedHolding holding;

  const HoldingTile({super.key, required this.holding});

  @override
  Widget build(BuildContext context) {
    final gain = holding.gain;
    final gainFraction = holding.gainFraction;
    final gainColor =
        (gain ?? 0) >= 0 ? AppTheme.gain : AppTheme.loss;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          holding.symbol.length > 5
              ? holding.symbol.substring(0, 5)
              : holding.symbol,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
      title: Text(
        holding.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        '${formatQuantity(holding.quantity)} shares'
        '${holding.accountCount > 1 ? ' · ${holding.accountCount} accounts' : ''}',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatCurrency(holding.value),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          if (gain != null && gainFraction != null)
            Text(
              '${formatCurrency(gain, showSign: true)} (${formatPercent(gainFraction)})',
              style: TextStyle(color: gainColor, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

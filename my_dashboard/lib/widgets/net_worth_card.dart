import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class NetWorthCard extends StatelessWidget {
  final double totalValue;
  final double totalGain;
  final double totalGainFraction;
  final int accountCount;

  const NetWorthCard({
    super.key,
    required this.totalValue,
    required this.totalGain,
    required this.totalGainFraction,
    required this.accountCount,
  });

  @override
  Widget build(BuildContext context) {
    final gainColor = totalGain >= 0 ? AppTheme.gain : AppTheme.loss;
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.surface,
              AppTheme.accent.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NET WORTH',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(totalValue),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  totalGain >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: gainColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${formatCurrency(totalGain, showSign: true)} '
                  '(${formatPercent(totalGainFraction)}) all time',
                  style: TextStyle(
                    color: gainColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Across $accountCount linked account${accountCount == 1 ? '' : 's'}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

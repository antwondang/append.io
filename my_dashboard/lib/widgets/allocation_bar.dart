import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Horizontal stacked bar + legend showing portfolio split by category.
class AllocationBar extends StatelessWidget {
  final Map<String, double> allocation;

  const AllocationBar({super.key, required this.allocation});

  @override
  Widget build(BuildContext context) {
    final total = allocation.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return const SizedBox.shrink();

    final entries = allocation.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                for (var i = 0; i < entries.length; i++)
                  Expanded(
                    flex: ((entries[i].value / total) * 1000).round(),
                    child: Container(
                      color: AppTheme.allocationColors[
                          i % AppTheme.allocationColors.length],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            for (var i = 0; i < entries.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.allocationColors[
                          i % AppTheme.allocationColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${entries[i].key} · '
                    '${formatPercent(entries[i].value / total, showSign: false)}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

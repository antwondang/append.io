import 'package:flutter/material.dart';

import '../models/account.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class AccountTile extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;

  const AccountTile({super.key, required this.account, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppTheme.surfaceLight,
        child: Text(
          account.institutionName.isNotEmpty
              ? account.institutionName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: AppTheme.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        account.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        [
          account.institutionName,
          account.category,
          if (account.mask != null) '••${account.mask}',
        ].join(' · '),
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: Text(
        formatCurrency(account.balance),
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

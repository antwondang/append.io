import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/account.dart';
import '../models/holding.dart';
import 'mock_data.dart';

/// Single source of truth for portfolio data.
///
/// In demo mode (no Supabase config) it serves [MockData]; otherwise it
/// reads the current user's rows from Supabase, which are populated by the
/// `sync-investments` edge function after a Plaid link.
class PortfolioService extends ChangeNotifier {
  PortfolioService._();
  static final PortfolioService instance = PortfolioService._();

  bool get isLive => AppConfig.isSupabaseConfigured;

  List<Account> accounts = [];
  List<Holding> holdings = [];
  bool isLoading = false;
  String? error;
  DateTime? lastUpdated;

  SupabaseClient get _db => Supabase.instance.client;

  double get totalValue =>
      accounts.fold(0, (sum, account) => sum + account.balance);

  double get totalCostBasis => holdings.fold(
      0, (sum, holding) => sum + (holding.costBasis ?? holding.value));

  double get totalGain => holdings.fold(0, (sum, h) => sum + (h.gain ?? 0));

  double get totalGainFraction =>
      totalCostBasis == 0 ? 0 : totalGain / totalCostBasis;

  /// Account values grouped by [Account.category], for the allocation chart.
  Map<String, double> get allocationByCategory {
    final map = <String, double>{};
    for (final account in accounts) {
      map[account.category] = (map[account.category] ?? 0) + account.balance;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  List<Holding> holdingsForAccount(String accountId) =>
      holdings.where((h) => h.accountId == accountId).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      if (!isLive) {
        // Demo mode: small delay so loading states are visible during dev.
        await Future<void>.delayed(const Duration(milliseconds: 350));
        accounts = List.of(MockData.accounts);
        holdings = List.of(MockData.holdings);
      } else {
        final accountRows = await _db.from('accounts').select();
        final holdingRows = await _db.from('holdings').select();
        accounts = (accountRows as List)
            .map((row) => Account.fromJson(row as Map<String, dynamic>))
            .toList();
        holdings = (holdingRows as List)
            .map((row) => Holding.fromJson(row as Map<String, dynamic>))
            .toList();
      }
      accounts.sort((a, b) => b.balance.compareTo(a.balance));
      lastUpdated = DateTime.now();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Asks the backend to re-pull holdings from Plaid, then reloads.
  Future<void> syncFromPlaid() async {
    if (!isLive) {
      await load();
      return;
    }
    await _db.functions.invoke('sync-investments');
    await load();
  }
}

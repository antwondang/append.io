/// A position held within an account.
class Holding {
  final String id;
  final String accountId;
  final String? ticker;
  final String name;
  final double quantity;
  final double price;
  final double value;
  final double? costBasis;

  const Holding({
    required this.id,
    required this.accountId,
    this.ticker,
    required this.name,
    required this.quantity,
    required this.price,
    required this.value,
    this.costBasis,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      ticker: json['ticker'] as String?,
      name: json['name'] as String? ?? 'Unknown security',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      value: (json['value'] as num?)?.toDouble() ?? 0,
      costBasis: (json['cost_basis'] as num?)?.toDouble(),
    );
  }

  double? get gain => costBasis == null ? null : value - costBasis!;

  double? get gainFraction =>
      (costBasis == null || costBasis == 0) ? null : (value - costBasis!) / costBasis!;

  String get displaySymbol => ticker ?? name.split(' ').first.toUpperCase();
}

/// Holdings of the same security aggregated across all accounts.
class AggregatedHolding {
  final String symbol;
  final String name;
  final double quantity;
  final double value;
  final double? costBasis;
  final int accountCount;

  const AggregatedHolding({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.value,
    this.costBasis,
    required this.accountCount,
  });

  double? get gain => costBasis == null ? null : value - costBasis!;

  double? get gainFraction =>
      (costBasis == null || costBasis == 0) ? null : (value - costBasis!) / costBasis!;

  static List<AggregatedHolding> aggregate(List<Holding> holdings) {
    final bySymbol = <String, List<Holding>>{};
    for (final h in holdings) {
      bySymbol.putIfAbsent(h.displaySymbol, () => []).add(h);
    }
    final result = bySymbol.entries.map((entry) {
      final list = entry.value;
      double quantity = 0, value = 0, costBasis = 0;
      var hasCostBasis = true;
      for (final h in list) {
        quantity += h.quantity;
        value += h.value;
        if (h.costBasis == null) {
          hasCostBasis = false;
        } else {
          costBasis += h.costBasis!;
        }
      }
      return AggregatedHolding(
        symbol: entry.key,
        name: list.first.name,
        quantity: quantity,
        value: value,
        costBasis: hasCostBasis ? costBasis : null,
        accountCount: list.map((h) => h.accountId).toSet().length,
      );
    }).toList();
    result.sort((a, b) => b.value.compareTo(a.value));
    return result;
  }
}

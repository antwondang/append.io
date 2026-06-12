/// Lightweight number formatting helpers (avoids pulling in `intl`).
library;

String _withThousands(String digits) {
  return digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
}

/// $12,345.67 — set [showSign] for +/- prefixes on changes.
String formatCurrency(double value, {bool showSign = false}) {
  final sign = value < 0
      ? '-'
      : showSign
          ? '+'
          : '';
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  return '$sign\$${_withThousands(parts[0])}.${parts[1]}';
}

/// $12.3K / $1.2M style for tight spaces.
String formatCurrencyCompact(double value) {
  final abs = value.abs();
  final sign = value < 0 ? '-' : '';
  if (abs >= 1e6) return '$sign\$${(abs / 1e6).toStringAsFixed(1)}M';
  if (abs >= 1e3) return '$sign\$${(abs / 1e3).toStringAsFixed(1)}K';
  return '$sign\$${abs.toStringAsFixed(0)}';
}

/// +1.23% style.
String formatPercent(double fraction, {bool showSign = true}) {
  final sign = fraction < 0
      ? '-'
      : showSign
          ? '+'
          : '';
  return '$sign${(fraction.abs() * 100).toStringAsFixed(2)}%';
}

/// Shares quantity: trims trailing zeros (e.g. 12, 3.5, 0.0231).
String formatQuantity(double quantity) {
  var s = quantity.toStringAsFixed(4);
  s = s.replaceFirst(RegExp(r'\.?0+$'), '');
  return s;
}

/// A linked financial account (brokerage, 401k, IRA, cash, ...).
class Account {
  final String id;
  final String name;
  final String institutionName;

  /// Plaid account type: investment, depository, credit, loan...
  final String type;

  /// Plaid subtype: 401k, roth, ira, brokerage, hsa, checking...
  final String? subtype;

  /// Last 2-4 digits of the account number.
  final String? mask;

  final double balance;

  const Account({
    required this.id,
    required this.name,
    required this.institutionName,
    required this.type,
    this.subtype,
    this.mask,
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Account',
      institutionName: json['institution_name'] as String? ?? 'Unknown',
      type: json['type'] as String? ?? 'investment',
      subtype: json['subtype'] as String?,
      mask: json['mask'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Human-friendly category used for grouping/allocation, derived from
  /// the Plaid type/subtype.
  String get category {
    final s = (subtype ?? '').toLowerCase();
    if (s.contains('401k') || s.contains('403b') || s.contains('457')) {
      return 'Retirement (Employer)';
    }
    if (s.contains('ira') || s.contains('roth')) return 'Retirement (IRA)';
    if (s.contains('hsa')) return 'HSA';
    if (type == 'investment') return 'Brokerage';
    if (type == 'depository') return 'Cash';
    return 'Other';
  }
}

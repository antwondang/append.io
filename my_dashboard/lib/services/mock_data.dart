import '../models/account.dart';
import '../models/holding.dart';

/// Demo portfolio shown when Supabase isn't configured, so the whole UI
/// can be developed and explored without a backend.
class MockData {
  MockData._();

  static const List<Account> accounts = [
    Account(
      id: 'acc-fidelity-401k',
      name: 'TECH CORP 401(K) PLAN',
      institutionName: 'Fidelity',
      type: 'investment',
      subtype: '401k',
      mask: '7712',
      balance: 84230.55,
    ),
    Account(
      id: 'acc-vanguard-roth',
      name: 'Roth IRA Brokerage',
      institutionName: 'Vanguard',
      type: 'investment',
      subtype: 'roth',
      mask: '4410',
      balance: 31894.12,
    ),
    Account(
      id: 'acc-schwab-brokerage',
      name: 'Individual Brokerage',
      institutionName: 'Charles Schwab',
      type: 'investment',
      subtype: 'brokerage',
      mask: '0098',
      balance: 27410.78,
    ),
    Account(
      id: 'acc-robinhood',
      name: 'Robinhood Investing',
      institutionName: 'Robinhood',
      type: 'investment',
      subtype: 'brokerage',
      mask: '5521',
      balance: 9482.36,
    ),
    Account(
      id: 'acc-fidelity-hsa',
      name: 'Health Savings Account',
      institutionName: 'Fidelity',
      type: 'investment',
      subtype: 'hsa',
      mask: '3307',
      balance: 6120.00,
    ),
  ];

  static const List<Holding> holdings = [
    // Fidelity 401k
    Holding(
      id: 'h1',
      accountId: 'acc-fidelity-401k',
      ticker: 'FXAIX',
      name: 'Fidelity 500 Index Fund',
      quantity: 312.441,
      price: 198.12,
      value: 61901.21,
      costBasis: 48210.00,
    ),
    Holding(
      id: 'h2',
      accountId: 'acc-fidelity-401k',
      ticker: 'FSPSX',
      name: 'Fidelity International Index Fund',
      quantity: 401.22,
      price: 52.10,
      value: 20903.56,
      costBasis: 19877.40,
    ),
    Holding(
      id: 'h3',
      accountId: 'acc-fidelity-401k',
      ticker: 'FXNAX',
      name: 'Fidelity US Bond Index Fund',
      quantity: 135.80,
      price: 10.50,
      value: 1425.78,
      costBasis: 1490.00,
    ),
    // Vanguard Roth IRA
    Holding(
      id: 'h4',
      accountId: 'acc-vanguard-roth',
      ticker: 'VTI',
      name: 'Vanguard Total Stock Market ETF',
      quantity: 88.0,
      price: 289.55,
      value: 25480.40,
      costBasis: 19360.00,
    ),
    Holding(
      id: 'h5',
      accountId: 'acc-vanguard-roth',
      ticker: 'VXUS',
      name: 'Vanguard Total International Stock ETF',
      quantity: 98.5,
      price: 65.11,
      value: 6413.72,
      costBasis: 5762.25,
    ),
    // Schwab brokerage
    Holding(
      id: 'h6',
      accountId: 'acc-schwab-brokerage',
      ticker: 'AAPL',
      name: 'Apple Inc',
      quantity: 42.0,
      price: 238.20,
      value: 10004.40,
      costBasis: 6510.00,
    ),
    Holding(
      id: 'h7',
      accountId: 'acc-schwab-brokerage',
      ticker: 'MSFT',
      name: 'Microsoft Corp',
      quantity: 18.0,
      price: 512.30,
      value: 9221.40,
      costBasis: 5868.00,
    ),
    Holding(
      id: 'h8',
      accountId: 'acc-schwab-brokerage',
      ticker: 'VTI',
      name: 'Vanguard Total Stock Market ETF',
      quantity: 28.25,
      price: 289.55,
      value: 8179.79,
      costBasis: 7344.50,
    ),
    // Robinhood
    Holding(
      id: 'h9',
      accountId: 'acc-robinhood',
      ticker: 'NVDA',
      name: 'NVIDIA Corp',
      quantity: 35.0,
      price: 171.20,
      value: 5992.00,
      costBasis: 3150.00,
    ),
    Holding(
      id: 'h10',
      accountId: 'acc-robinhood',
      ticker: 'AMZN',
      name: 'Amazon.com Inc',
      quantity: 15.5,
      price: 225.18,
      value: 3490.29,
      costBasis: 2945.00,
    ),
    // HSA
    Holding(
      id: 'h11',
      accountId: 'acc-fidelity-hsa',
      ticker: 'FZROX',
      name: 'Fidelity ZERO Total Market Index Fund',
      quantity: 310.0,
      price: 19.74,
      value: 6119.40,
      costBasis: 5580.00,
    ),
  ];
}

enum AccountType { corrente, poupanca, cartaoCredito, carteira, investimento, outro }

/// A named account/wallet that transactions belong to (e.g. "Conta
/// Corrente", "Cartão Nubank"). [initialBalance] is the balance before
/// any tracked transaction — the account's real-world balance is
/// `initialBalance + sum(linked transactions)`, computed live by
/// `AccountBalance` rather than stored as a field (so it's never stale).
class AccountModel {
  /// Stable identifier — maps to a Firestore document ID later.
  final String id;

  final String name;
  final AccountType type;
  final double initialBalance;

  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    this.initialBalance = 0,
  });

  AccountModel copyWith({String? name, AccountType? type, double? initialBalance}) {
    return AccountModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
    );
  }
}
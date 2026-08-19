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

  // NOVO: data em que a conta foi criada. Necessário para os
  // relatórios de evolução de saldo não contarem o initialBalance
  // desta conta em meses anteriores à sua criação — sem isto, o
  // gráfico "inventa" saldo em meses onde a conta nem existia ainda.
  // Nullable para não quebrar leitura de contas antigas já existentes
  // no Firestore, criadas antes desta mudança (caem em null, tratado
  // como "sempre existiu" no relatório — ver nota no report_summary).
  final DateTime? createdAt;

  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    this.initialBalance = 0,
    this.createdAt,
  });

  AccountModel copyWith({
    String? name,
    AccountType? type,
    double? initialBalance,
    DateTime? createdAt,
  }) {
    return AccountModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
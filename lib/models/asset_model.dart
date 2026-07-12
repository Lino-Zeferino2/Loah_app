enum AssetType { emergencyFund, stocks, realEstate, cash, other }

/// One item of net worth: a stock position, a property, the emergency
/// fund, cash on hand, etc. [currentValue] is a manually-updated
/// snapshot (like [GoalModel.current]) — there's no live market feed,
/// the user just tells Loah what it's worth right now.
class AssetModel {
  /// Stable identifier — maps to a Firestore document ID later.
  final String id;

  final String name;
  final AssetType type;
  final double currentValue;

  /// Optional free-text notes (e.g. "Apartamento no bairro X", ticker
  /// symbols, account/institution name).
  final String? notes;

  final DateTime updatedAt;

  const AssetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.currentValue,
    this.notes,
    required this.updatedAt,
  });

  AssetModel copyWith({
    String? name,
    AssetType? type,
    double? currentValue,
    String? notes,
    DateTime? updatedAt,
  }) {
    return AssetModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentValue: currentValue ?? this.currentValue,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
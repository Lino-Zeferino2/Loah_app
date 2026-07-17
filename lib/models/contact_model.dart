enum InteractionType { call, message, meeting, other }

extension InteractionTypeLabel on InteractionType {
  String get label => switch (this) {
        InteractionType.call => 'Ligação',
        InteractionType.message => 'Mensagem',
        InteractionType.meeting => 'Encontro',
        InteractionType.other => 'Outro',
      };
}

/// One logged touchpoint with a contact — a call, a message, meeting up
/// in person, etc. Stored as a dated event (not a running counter) so
/// "how many times this week/month" can always be computed fresh
/// instead of drifting out of sync.
class ContactInteraction {
  final DateTime date;
  final InteractionType type;
  final String? note;

  const ContactInteraction({required this.date, required this.type, this.note});
}

/// A single person in the "Contatos" screen: favorites carousel and/or
/// the alphabetical list below it.
class ContactModel {
  /// Stable identifier — maps to a Firestore document ID later.
  final String id;

  final String name;
  final String? email;
  final String? phone;
  final String relationshipTag; // e.g. "Namorada", "Amigo", "Colega"
  final String? avatarUrl;
  final bool isFavorite;

  /// How often (in days) the user wants to stay in touch with this
  /// person — e.g. 7 for "toda semana". Null means no reminder is set.
  /// Drives [isOverdue].
  final int? desiredContactFrequencyDays;

  final List<ContactInteraction> interactions;

  const ContactModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.relationshipTag,
    this.avatarUrl,
    this.isFavorite = false,
    this.desiredContactFrequencyDays,
    this.interactions = const [],
  });

  ContactModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? relationshipTag,
    String? avatarUrl,
    bool? isFavorite,
    int? desiredContactFrequencyDays,
    bool clearFrequency = false,
    List<ContactInteraction>? interactions,
  }) {
    return ContactModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      relationshipTag: relationshipTag ?? this.relationshipTag,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      desiredContactFrequencyDays:
          clearFrequency ? null : (desiredContactFrequencyDays ?? this.desiredContactFrequencyDays),
      interactions: interactions ?? this.interactions,
    );
  }

  /// First letter of [name], used to group contacts alphabetically
  /// (e.g. "Adriana Silva" -> "A").
  String get initialLetter => name.isEmpty ? '#' : name[0].toUpperCase();

  /// Two-letter fallback shown when there's no [avatarUrl].
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  DateTime? get lastContactedAt {
    if (interactions.isEmpty) return null;
    return interactions.map((i) => i.date).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Days since the last logged interaction. -1 if there's no history
  /// at all (never contacted, or no interactions logged yet).
  int get daysSinceLastContact {
    final last = lastContactedAt;
    if (last == null) return -1;
    return DateTime.now().difference(last).inDays;
  }

  /// True once [daysSinceLastContact] exceeds [desiredContactFrequencyDays]
  /// — drives the "faz tempo que não fala" alert. Always false if no
  /// frequency was set, or if there's no contact history yet.
  bool get isOverdue {
    final frequency = desiredContactFrequencyDays;
    if (frequency == null) return false;
    final days = daysSinceLastContact;
    if (days == -1) return false;
    return days > frequency;
  }

  int interactionsInLast(Duration period) {
    final cutoff = DateTime.now().subtract(period);
    return interactions.where((i) => i.date.isAfter(cutoff)).length;
  }
}
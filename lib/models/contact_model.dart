/// A single person in the "Contatos" screen: favorites carousel and/or
/// the alphabetical list below it.
class ContactModel {
  final String name;
  final String? email;
  final String? phone;
  final String relationshipTag; // e.g. "Namorada", "Amigo", "Colega"
  final String? avatarUrl;
  final bool isFavorite;

  const ContactModel({
    required this.name,
    this.email,
    this.phone,
    required this.relationshipTag,
    this.avatarUrl,
    this.isFavorite = false,
  });

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
}
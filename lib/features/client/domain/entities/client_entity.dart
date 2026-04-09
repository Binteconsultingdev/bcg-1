class ClientEntity {
  final int id;
  final String? displayName;
  final num? owes;

  ClientEntity({
    required this.id,
    this.displayName,
    this.owes,
  });

  String get cleanName {
    if (displayName == null) return '';
    return displayName!.replaceFirst(RegExp(r'^\(\d+\)\s*'), '');
  }
}
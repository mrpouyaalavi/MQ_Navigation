class TransitStop {
  const TransitStop({required this.id, required this.name});

  final String id;
  final String name;

  factory TransitStop.fromJson(Map<String, dynamic> json) {
    return TransitStop(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
    );
  }
}

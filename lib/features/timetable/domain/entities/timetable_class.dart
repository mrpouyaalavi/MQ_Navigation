class TimetableClass {
  const TimetableClass({
    required this.location,
    required this.name,
    required this.startIso,
  });

  final String location;
  final String name;
  final String startIso;

  DateTime get startTime => DateTime.parse(startIso).toLocal();

  Map<String, dynamic> toJson() {
    return {'location': location, 'name': name, 'startIso': startIso};
  }

  factory TimetableClass.fromJson(Map<String, dynamic> json) {
    return TimetableClass(
      location: (json['location'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      startIso:
          (json['startIso'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }
}

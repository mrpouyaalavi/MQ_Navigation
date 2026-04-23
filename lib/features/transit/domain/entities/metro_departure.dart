class MetroDeparture {
  const MetroDeparture({
    required this.destination,
    required this.line,
    required this.minutesUntilDeparture,
    required this.platform,
  });

  final String destination;
  final String line;
  final int minutesUntilDeparture;
  final String platform;

  factory MetroDeparture.fromJson(Map<String, dynamic> json) {
    return MetroDeparture(
      destination: (json['destination'] as String?) ?? '',
      line: (json['line'] as String?) ?? '',
      minutesUntilDeparture:
          (json['minutesUntilDeparture'] as num?)?.toInt() ?? 0,
      platform: (json['platform'] as String?) ?? '',
    );
  }
}

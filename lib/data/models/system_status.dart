/// System status model — from GET /api/status
class SystemStatus {
  final bool online;
  final bool isRecording;
  final DateTime timestamp;

  const SystemStatus({
    required this.online,
    required this.isRecording,
    required this.timestamp,
  });

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      online: json['online'] as bool? ?? false,
      isRecording: json['isRecording'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  factory SystemStatus.offline() {
    return SystemStatus(
      online: false,
      isRecording: false,
      timestamp: DateTime.now(),
    );
  }
}

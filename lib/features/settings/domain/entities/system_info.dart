class SystemInfo {
  final double cpuTemp;
  final double diskUsedGb;
  final double diskTotalGb;
  final int uptimeHours;
  final int uptimeMinutes;

  const SystemInfo({
    required this.cpuTemp,
    required this.diskUsedGb,
    required this.diskTotalGb,
    required this.uptimeHours,
    required this.uptimeMinutes,
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      cpuTemp: (json['cpuTemp'] as num).toDouble(),
      diskUsedGb: (json['diskUsedGb'] as num).toDouble(),
      diskTotalGb: (json['diskTotalGb'] as num).toDouble(),
      uptimeHours: json['uptimeHours'] as int,
      uptimeMinutes: json['uptimeMinutes'] as int,
    );
  }

  factory SystemInfo.empty() {
    return const SystemInfo(
      cpuTemp: 0,
      diskUsedGb: 0,
      diskTotalGb: 0,
      uptimeHours: 0,
      uptimeMinutes: 0,
    );
  }
}

/// Transcript speaker block — a single speech segment
class SpeakerBlock {
  final String speaker;
  final Duration timestamp;
  final String text;

  const SpeakerBlock({
    required this.speaker,
    required this.timestamp,
    required this.text,
  });

  factory SpeakerBlock.fromJson(Map<String, dynamic> json) {
    return SpeakerBlock(
      speaker: json['speaker'] as String? ?? 'Unknown',
      timestamp: Duration(seconds: json['timestamp'] as int? ?? 0),
      text: json['text'] as String? ?? '',
    );
  }
}

/// Analysis result model — parsed from backend JSON output files
class AnalysisResult {
  final String id;
  final String title;
  final String filename;
  final List<SpeakerBlock> transcript;
  final String summary;
  final List<String> actionItems;
  final List<String> tags;
  final DateTime date;
  final Duration duration;
  final int participantCount;
  final String? emailDeliveryStatus;

  const AnalysisResult({
    required this.id,
    required this.title,
    required this.filename,
    this.transcript = const [],
    this.summary = '',
    this.actionItems = const [],
    this.tags = const [],
    required this.date,
    required this.duration,
    this.participantCount = 1,
    this.emailDeliveryStatus,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Recording',
      filename: json['filename'] as String? ?? '',
      transcript: (json['transcript'] as List<dynamic>?)
              ?.map((e) => SpeakerBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] as String? ?? '',
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      duration: Duration(seconds: json['duration'] as int? ?? 0),
      participantCount: json['participantCount'] as int? ?? 1,
      emailDeliveryStatus: json['emailDeliveryStatus'] as String?,
    );
  }
}

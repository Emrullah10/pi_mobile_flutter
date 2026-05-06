import 'package:intl/intl.dart';

/// Utility formatters for dates, durations, timestamps
class Formatters {
  Formatters._();

  /// Format Duration as HH:MM:SS
  static String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Format Duration as MM:SS (short)
  static String formatDurationShort(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format DateTime as "Oct 24, 14:30"
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM d, HH:mm').format(date);
  }

  /// Format DateTime as "October 24, 2023"
  static String formatDateFull(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  /// Format relative time "45m ago", "2h ago"
  static String formatRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDateShort(date);
  }

  /// Format timestamp for speaker blocks "00:01:12"
  static String formatTimestamp(Duration position) {
    final hours = position.inHours.toString().padLeft(2, '0');
    final minutes = (position.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (position.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

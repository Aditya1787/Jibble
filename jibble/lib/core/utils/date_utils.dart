class AppDateUtils {
  static String timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 365) return "${(duration.inDays / 365).floor()}y";
    if (duration.inDays > 30) return "${(duration.inDays / 30).floor()}mo";
    if (duration.inDays > 0) return "${duration.inDays}d";
    if (duration.inHours > 0) return "${duration.inHours}h";
    if (duration.inMinutes > 0) return "${duration.inMinutes}m";
    return "just now";
  }
}

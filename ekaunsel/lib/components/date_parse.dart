import 'package:intl/intl.dart';

String timeAgo(String createdAt) {
  DateTime now = DateTime.now();
  DateTime createdTime = DateTime.parse(createdAt); // Parse the created_at string

  Duration difference = now.difference(createdTime);

  if (difference.inSeconds < 60) {
    return 'Just now'; // Less than a minute ago
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago'; // Minutes ago
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago'; // Hours ago
  } else if (difference.inDays < 30) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago'; // Days ago
  } else if (difference.inDays < 365) {
    return DateFormat('MMM d').format(createdTime); // Display month and day for less than a year
  } else {
    return DateFormat('MMM d, yyyy').format(createdTime); // Display full date for older than a year
  }
}
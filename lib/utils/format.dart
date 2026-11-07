import 'package:intl/intl.dart';

String timeAgo(DateTime? d) {
  if (d == null) return 'Just now';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return DateFormat('d MMM yyyy').format(d);
}
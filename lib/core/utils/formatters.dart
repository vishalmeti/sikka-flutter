import 'package:intl/intl.dart';

final _indianFormat = NumberFormat('#,##,###', 'en_IN');

String fmtNumber(num n) => _indianFormat.format(n);

String fmtRupee(num n) => '₹${_indianFormat.format(n)}';

/// Human-friendly relative timestamp, e.g. "Today, 6:42 PM", "Yesterday, 8:11 PM",
/// "Mon, 7:24 PM" (within the last week), or "12 May" for anything older.
String fmtRelativeTime(DateTime dt) {
  final local = dt.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thatDay = DateTime(local.year, local.month, local.day);
  final diffDays = today.difference(thatDay).inDays;
  final time = DateFormat('h:mm a').format(local);

  if (diffDays == 0) return 'Today, $time';
  if (diffDays == 1) return 'Yesterday, $time';
  if (diffDays > 1 && diffDays < 7) return '${DateFormat('EEE').format(local)}, $time';
  return DateFormat('d MMM').format(local);
}

import 'package:intl/intl.dart';

String dateFormat(DateTime date) {
  final day = date.day;
  final suffix = _getDaySuffix(day);
  final month = DateFormat.MMM().format(date); // Full month name
  final year = date.year;

  return '$day$suffix $month $year';
}

String _getDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

String daysAgo(DateTime date) {
  final days = (DateTime.now().difference(date).inDays).abs() + 1;
  return '$days ${days == 1 ? 'day' : 'days'} ago';
}

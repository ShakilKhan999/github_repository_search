import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime dateTime) {
    // Requirement: MM-DD-YYYY HH:MM
    return DateFormat('MM-dd-yyyy HH:mm').format(dateTime.toLocal());
  }
}

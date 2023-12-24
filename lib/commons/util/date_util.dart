import 'package:date_format/date_format.dart';

class DateUtil {
  static String dateToYmd(DateTime date) {
    return formatDate(date, [yyyy, '-', mm, '-', dd]);
  }

  static String dateToMd(DateTime date) {
    return formatDate(date, [m, '.', d]);
  }

  static int dayStart(int timeMills) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeMills);
    var year = date.year;
    var month = date.month;
    var day = date.day;
    var dayStartDate = DateTime(year, month, day);
    return dayStartDate.millisecondsSinceEpoch;
  }

  static int dayEnd(int timeMills) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeMills);
    var tom = addDays(date, 1);
    var year = tom.year;
    var month = tom.month;
    var day = tom.day;
    var dayStartDate = DateTime(year, month, day);
    return dayStartDate.millisecondsSinceEpoch - 1;
  }

  static DateTime addDays(DateTime date, int days) {
    var dayMill = 24 * 60 * 60 * 1000;
    return date.add(Duration(milliseconds: dayMill * days));
  }
}

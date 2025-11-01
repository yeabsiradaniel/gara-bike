class EthiopianCalendar {
  final int year;
  final int month;
  final int day;

  EthiopianCalendar({required this.year, required this.month, required this.day});

  static bool _isGregorianLeap(int y) {
    return (y % 4 == 0 && (y % 100 != 0 || y % 400 == 0));
  }

  static int _newYearDayForGregorianYear(int y) {
    return _isGregorianLeap(y + 1) ? 12 : 11;
  }

  factory EthiopianCalendar.fromGregorian(DateTime gregorianDate) {
    final gy = gregorianDate.year;
    final gm = gregorianDate.month;
    final gd = gregorianDate.day;

    final nyDayThisYear = _newYearDayForGregorianYear(gy);
    int ey;
    DateTime newYearGregorian;

    if (gm > 9 || (gm == 9 && gd >= nyDayThisYear)) {
      ey = gy - 7;
      newYearGregorian = DateTime(gy, 9, nyDayThisYear);
    } else {
      ey = gy - 8;
      final prev = gy - 1;
      newYearGregorian = DateTime(prev, 9, _newYearDayForGregorianYear(prev));
    }

    final delta = gregorianDate.difference(newYearGregorian).inDays;
    final monthIndex = (delta / 30).floor();
    final day = (delta % 30) + 1;
    final em = monthIndex + 1;

    return EthiopianCalendar(year: ey, month: em, day: day);
  }

  String get monthName {
    switch (month) {
      case 1:
        return 'መስከረም';
      case 2:
        return 'ጥቅምት';
      case 3:
        return 'ኅዳር';
      case 4:
        return 'ታኅሣሥ';
      case 5:
        return 'ጥር';
      case 6:
        return 'የካቲት';
      case 7:
        return 'መጋቢት';
      case 8:
        return 'ሚያዝያ';
      case 9:
        return 'ግንቦት';
      case 10:
        return 'ሰኔ';
      case 11:
        return 'ሐምሌ';
      case 12:
        return 'ነሐሴ';
      case 13:
        return 'ጳጉሜ';
      default:
        return '';
    }
  }
}
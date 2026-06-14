import 'package:orthodox_church_ramallah/services/saint_day_info.dart';
import 'package:orthodox_church_ramallah/services/saints_data_2026.dart';


class SaintsHelper {
  static final Map<int, Map<String, SaintDayInfo>> _cache = {};


  // ─── Pascha dates (Gregorian) ───
  static final Map<int, DateTime> _paschaByYear = {
    2024: DateTime(2024, 5, 5),
    2025: DateTime(2025, 4, 20),
    2026: DateTime(2026, 4, 12),
    2027: DateTime(2027, 5, 2),
    2028: DateTime(2028, 4, 16),
    2029: DateTime(2029, 4, 8),
    2030: DateTime(2030, 4, 28),
    2031: DateTime(2031, 4, 13),
    2032: DateTime(2032, 5, 2),
    2033: DateTime(2033, 4, 24),
    2034: DateTime(2034, 4, 9),
    2035: DateTime(2035, 4, 29),
  };


  // ─── Moveable feast offsets from Pascha ───
  static const List<int> _moveableOffsets = [
    -70, -63, -56, -49, -48,
    -7, -6, -5, -4, -3, -2, -1,
    0, 1, 7, 25, 39, 49, 50, 56,
  ];


  // ─── 2026 moveable feast keys ───
  static final Set<String> _moveable2026Keys = () {
    final pascha2026 = _paschaByYear[2026]!;
    return _moveableOffsets.map((offset) {
      final date = pascha2026.add(Duration(days: offset));
      return '${date.month}-${date.day}';
    }).toSet();
  }();


  // ─── Text detection ───


  static bool isFastDay(String note) => note.contains('صوم');


  static bool isFeastDay(String title) {
    const keywords = [
      'عيد', 'الفصح', 'الميلاد', 'الظهور', 'التجلي', 'الصعود',
      'العنصرة', 'الشعانين', 'دخول السيد', 'دخول السيدة',
      'رقاد', 'ميلاد والدة', 'بشارة والدة', 'رفع الصليب',
      'تقدمة', 'وداع', 'برامون',
    ];
    return keywords.any((k) => title.contains(k));
  }


  static SaintDayInfo _process(SaintDayInfo info, int year) {
    return info.copyWith(
      isFast: year == 2026 ? isFastDay(info.note) : false,
      isFeast: isFeastDay(info.title),
    );
  }


  // ─── Fasting periods ───


  static bool _isGreatLent(DateTime date, DateTime pascha) {
    final lentStart = pascha.subtract(const Duration(days: 48));
    return !date.isBefore(lentStart) && date.isBefore(pascha);
  }


  static bool _isApostlesFast(DateTime date, DateTime pascha) {
    final start = pascha.add(const Duration(days: 57));
    final end = DateTime(date.year, 7, 12);
    return !date.isBefore(start) && !date.isAfter(end);
  }


  static bool _isBrightWeek(DateTime date, DateTime pascha) {
    return !date.isBefore(pascha) &&
        date.isBefore(pascha.add(const Duration(days: 7)));
  }


  static bool _isDormitionFast(DateTime date) {
    final start = DateTime(date.year, 8, 14);
    final end = DateTime(date.year, 8, 27);
    return !date.isBefore(start) && !date.isAfter(end);
  }


  static bool _isNativityFast(DateTime date) {
    if (date.month >= 11 && date.day >= 28) return true;
    if (date.month == 12) return true;
    if (date.month == 1 && date.day <= 6) return true;
    return false;
  }


  // ─── Weekly fast (Wednesday & Friday) ───
  static bool _isWeeklyFast(DateTime date, DateTime pascha) {
    // Check if it's Wednesday or Friday
    if (date.weekday != DateTime.wednesday && date.weekday != DateTime.friday) {
      return false;
    }

    // Exclude Bright Week (already handled by _isBrightWeek, but double-check)
    if (_isBrightWeek(date, pascha)) {
      return false;
    }

    // Exclude Wednesday and Friday after Pharisee and Publican Sunday (-70 days from Pascha)
    final phariseeSunday = pascha.subtract(const Duration(days: 70));
    final wednesdayAfterPharisee = phariseeSunday.add(const Duration(days: 3)); // -68 days
    final fridayAfterPharisee = phariseeSunday.add(const Duration(days: 5)); // -66 days

    if (date.isAtSameMomentAs(wednesdayAfterPharisee) || 
        date.isAtSameMomentAs(fridayAfterPharisee)) {
      return false;
    }

    return true;
  }


  // ─── Moveable feasts ───


  static Map<String, SaintDayInfo> _moveableFeasts(
      DateTime pascha, Map<String, SaintDayInfo> baseData) {
    final map = <String, SaintDayInfo>{};


    void add(int daysFromPascha, String title, String note) {
      final date = pascha.add(Duration(days: daysFromPascha));
      final key = '${date.month}-${date.day}';
      final existing = baseData[key];


      if (existing != null) {
        map[key] = existing.copyWith(
          title: '$title\n${existing.title}',
          note: note.isNotEmpty
              ? (existing.note.isNotEmpty ? '$note، ${existing.note}' : note)
              : existing.note,
          isFeast: true,
          isFast: false, // No note checking - fasting determined by periods only
        );
      } else {
        map[key] = SaintDayInfo(
          title: title,
          note: note,
          isFeast: true,
          isFast: false, // No note checking - fasting determined by periods only
        );
      }
    }


    add(-70, 'أحد الفريسي والعشار', '');
    add(-63, 'أحد الابن الشاطر', '');
    add(-56, 'أحد مرفع اللحم (الدينونة)', '');
    add(-49, 'أحد مرفع الجبن (الغفران)', 'صوم');
    add(-48, 'إثنين الصوم الكبير (بداية الصوم الكبير)', 'صوم انقطاعي');
    add(-7, 'أحد الشعانين (دخول الرب أورشليم)', 'صوم');
    add(-6, 'الإثنين العظيم', 'صوم انقطاعي');
    add(-5, 'الثلاثاء العظيم', 'صوم انقطاعي');
    add(-4, 'الأربعاء العظيم', 'صوم انقطاعي');
    add(-3, 'خميس الأسرار (العشاء الأخير)', 'صوم انقطاعي');
    add(-2, 'الجمعة العظيمة (جمعة الصلب)', 'صوم انقطاعي');
    add(-1, 'سبت النور', 'صوم انقطاعي');
    add(0, 'عيد الفصح المجيد (القيامة)', '');
    add(1, 'إثنين الباعوث', '');
    add(7, 'أحد توما', '');
    add(25, 'نصف العنصرة', '');
    add(39, 'عيد الصعود الإلهي', '');
    add(49, 'عيد العنصرة (حلول الروح القدس)', '');
    add(50, 'إثنين الروح القدس', '');
    add(56, 'أحد جميع القديسين', '');


    return map;
  }


  // ─── Get processed data for any year ───


    static Map<String, SaintDayInfo> getProcessedData(int year) {
    if (_cache.containsKey(year)) return _cache[year]!;


    final data = Map<String, SaintDayInfo>.from(
      saintsData2026.map((key, info) => MapEntry(key, _process(info, year))),
    );


    // For non-2026 years, remove entries that have 2026 moveable feast data
    if (year != 2026) {
      for (final key in _moveable2026Keys) {
        data.remove(key);
      }
    }


    final pascha = _paschaByYear[year];
    if (pascha != null) {
      data.addAll(_moveableFeasts(pascha, data));


      data.updateAll((key, info) {
        final parts = key.split('-');
        final date = DateTime(year, int.parse(parts[0]), int.parse(parts[1]));


        bool isFast = info.isFast;


        if (_isGreatLent(date, pascha) && !_isBrightWeek(date, pascha)) {
          isFast = true;
        }
        if (_isApostlesFast(date, pascha)) {
          isFast = true;
        }
        if (_isDormitionFast(date)) {
          isFast = true;
        }
        if (_isNativityFast(date)) {
          isFast = true;
        }
        if (_isWeeklyFast(date, pascha)) {
          isFast = true;
        }
        if (_isBrightWeek(date, pascha)) {
          isFast = false;
        }


        return isFast != info.isFast ? info.copyWith(isFast: isFast) : info;
      });
    }


    _cache[year] = data;
    return data;
  }


  // ─── Public API ───


  static SaintDayInfo? infoForDate(DateTime date) {
    final data = getProcessedData(date.year);
    return data['${date.month}-${date.day}'];
  }


  static DateTime? getPaschaDate(int year) => _paschaByYear[year];
}
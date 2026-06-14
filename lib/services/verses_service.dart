import '/data/daily_verses.dart';

class BibleVerseService {
  static String getVerseOfTheDay() {
    // Get day of year (1-365)
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(startOfYear).inDays;
    
    // Get verse for today (cycle through list)
    final index = dayOfYear % dailyVerses.length;
    return dailyVerses[index];
  }
}
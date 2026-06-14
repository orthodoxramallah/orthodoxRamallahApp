import 'package:flutter/material.dart';
import '../database/bible_database.dart';
import '../widgets/offline_indicator.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  List<int> books = <int>[];
  List<int> chapters = <int>[];
  List<Map<String, Object?>> verses = <Map<String, Object?>>[];

  int? selectedBook;
  int? selectedChapter;
  bool loading = true;
  String? error;

  static const Map<int, String> arabicBookNames66 = {
    1: 'التكوين',
    2: 'الخروج',
    3: 'اللاويين',
    4: 'العدد',
    5: 'التثنية',
    6: 'يشوع',
    7: 'القضاة',
    8: 'راعوث',
    9: 'صموئيل الأول',
    10: 'صموئيل الثاني',
    11: 'الملوك الأول',
    12: 'الملوك الثاني',
    13: 'أخبار الأيام الأول',
    14: 'أخبار الأيام الثاني',
    15: 'عزرا',
    16: 'نحميا',
    17: 'أستير',
    18: 'أيوب',
    19: 'المزامير',
    20: 'الأمثال',
    21: 'الجامعة',
    22: 'نشيد الأنشاد',
    23: 'إشعياء',
    24: 'إرميا',
    25: 'مراثي إرميا',
    26: 'حزقيال',
    27: 'دانيال',
    28: 'هوشع',
    29: 'يوئيل',
    30: 'عاموس',
    31: 'عوبديا',
    32: 'يونان',
    33: 'ميخا',
    34: 'ناحوم',
    35: 'حبقوق',
    36: 'صفنيا',
    37: 'حجي',
    38: 'زكريا',
    39: 'ملاخي',
    40: 'إنجيل متى',
    41: 'إنجيل مرقس',
    42: 'إنجيل لوقا',
    43: 'إنجيل يوحنا',
    44: 'أعمال الرسل',
    45: 'رومية',
    46: 'كورنثوس الأولى',
    47: 'كورنثوس الثانية',
    48: 'غلاطية',
    49: 'أفسس',
    50: 'فيلبي',
    51: 'كولوسي',
    52: 'تسالونيكي الأولى',
    53: 'تسالونيكي الثانية',
    54: 'تيموثاوس الأولى',
    55: 'تيموثاوس الثانية',
    56: 'تيطس',
    57: 'فليمون',
    58: 'العبرانيين',
    59: 'يعقوب',
    60: 'بطرس الأولى',
    61: 'بطرس الثانية',
    62: 'يوحنا الأولى',
    63: 'يوحنا الثانية',
    64: 'يوحنا الثالثة',
    65: 'يهوذا',
    66: 'رؤيا يوحنا اللاهوتي',
  };

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      books = await BibleDatabase.getBooks();
      if (!mounted) return;
      if (books.isNotEmpty) {
        selectedBook = books.first;
        await _loadChapters(selectedBook!);
      }
    } catch (e) {
      if (!mounted) return;
      error = 'تعذر تحميل الأسفار: ';
    } finally {
      if (mounted) {
        loading = false;
        setState(() {});
      }
    }
  }

  Future<void> _loadChapters(int book) async {
    try {
      chapters = await BibleDatabase.getChapters(book);
      if (!mounted) return;
      verses = [];
      if (chapters.isNotEmpty) {
        selectedChapter = chapters.first;
        await _loadVerses(book, selectedChapter!);
      }
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      error = 'تعذر تحميل الإصحاحات: ';
      setState(() {});
    }
  }

  Future<void> _loadVerses(int book, int chapter) async {
    try {
      verses = await BibleDatabase.getVerses(book, chapter);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      error = 'تعذر تحميل الأعداد: ';
      setState(() {});
    }
  }

  String _resolveBookName(int bookId) =>
      arabicBookNames66[bookId] ?? 'سفر رقم ';

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return OfflineIndicator(
        child: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('الكتاب المقدس', textDirection: TextDirection.rtl),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              error!,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final appBarTitle = selectedBook != null
        ? _resolveBookName(selectedBook!)
        : 'الكتاب المقدس';
    final bookValueValid = selectedBook != null && books.contains(selectedBook);
    final chapterValueValid =
        selectedChapter != null && chapters.contains(selectedChapter);
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, textDirection: TextDirection.rtl),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: bookValueValid ? selectedBook : null,
                    hint: const Text(
                      'اختر السفر',
                      textDirection: TextDirection.rtl,
                    ),
                    items: books
                        .map(
                          (b) => DropdownMenuItem(
                            value: b,
                            child: Text(
                              _resolveBookName(b),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        selectedBook = value;
                        selectedChapter = null;
                        chapters = [];
                        verses = [];
                      });
                      await _loadChapters(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: chapterValueValid ? selectedChapter : null,
                    hint: const Text(
                      'اختر الإصحاح',
                      textDirection: TextDirection.rtl,
                    ),
                    items: chapters
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              'الإصحاح $c',
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value == null || selectedBook == null) return;
                      setState(() {
                        selectedChapter = value;
                        verses = [];
                      });
                      await _loadVerses(selectedBook!, value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: verses.isEmpty
                  ? const Center(
                      child: Text(
                        'اختر السفر والإصحاح للعرض',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.separated(
                      itemCount: verses.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final v = verses[index];
                        final verseNo = (v['verse'] is num)
                            ? (v['verse'] as num).toInt()
                            : int.tryParse('') ?? 0;
                        final text = v['text']?.toString() ?? '';
                        return Text(
                          '$verseNo.  $text',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 18, height: 1.4),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

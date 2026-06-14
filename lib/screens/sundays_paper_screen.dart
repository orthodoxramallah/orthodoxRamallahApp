import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';

class SundaysPaperScreen extends StatefulWidget {
  const SundaysPaperScreen({super.key});

  @override
  State<SundaysPaperScreen> createState() => _SundaysPaperScreenState();
}

class _SundaysPaperScreenState extends State<SundaysPaperScreen> {
  final List<int> _years = [2024, 2025, 2026,2027,2028,2029,2030];
  final List<Map<String, String>> _months = const [
    {'label': 'كانون ثاني', 'abbr': 'jan'},
    {'label': 'شباط', 'abbr': 'feb'},
    {'label': 'اذار', 'abbr': 'mar'},
    {'label': 'نيسان', 'abbr': 'apr'},
    {'label': 'ايار', 'abbr': 'may'},
    {'label': 'حزيران', 'abbr': 'jun'},
    {'label': 'تموز', 'abbr': 'jul'},
    {'label': 'اب', 'abbr': 'aug'},
    {'label': 'ايلول', 'abbr': 'sep'},
    {'label': 'تشرين اول', 'abbr': 'oct'},
    {'label': 'تشرين ثاني', 'abbr': 'nov'},
    {'label': 'كانون اول', 'abbr': 'dec'},
  ];

  late int _selectedYear;
  late int _selectedMonthIndex;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = _years.contains(now.year) ? now.year : _years.last;
    _selectedMonthIndex = now.month - 1;
  }

  List<DateTime> _sundaysInMonth(int year, int month) {
    final days = <DateTime>[];
    final firstDay = DateTime(year, month, 1);
    final int offset = (DateTime.sunday - firstDay.weekday + 7) % 7;
    DateTime current = firstDay.add(Duration(days: offset));
    while (current.month == month) {
      days.add(current);
      current = current.add(const Duration(days: 7));
    }
    return days;
  }

  String _arabicMonthName(int month) {
    return _months[month - 1]['label']!;
  }

  String _buildSundayUrl(DateTime sunday) {
    final yearShort = sunday.year % 100;
    final monthAbbr = _months[sunday.month - 1]['abbr']!;
    final day = sunday.day.toString();
    final month = sunday.month.toString();
    return 'https://www.lightchrist.org/bul/$yearShort/$monthAbbr/${day}_${month}_${sunday.year}.pdf';
  }

  void _openSundayPdf(DateTime sunday) {
    final url = _buildSundayUrl(sunday);
    final label = '${sunday.day.toString()} ${_arabicMonthName(sunday.month)} ${sunday.year}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NetworkPdfViewerScreen(
          title: 'صحيفة الأحد - $label',
          pdfUrl: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sundays = _sundaysInMonth(_selectedYear, _selectedMonthIndex + 1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نشرة يوم الأحد'),
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'اختر أحد أيام الأحد لفتح نشرة الأسبوع بصيغة PDF.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'يتم تحميل الملف من الرابط الرسمي حسب تاريخ يوم الأحد المختار.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'السنة',
                        border: OutlineInputBorder(),
                      ),
                      items: _years
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedMonthIndex,
                      decoration: const InputDecoration(
                        labelText: 'الشهر',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        _months.length,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text(_months[index]['label']!),
                        ),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedMonthIndex = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: sundays.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sunday = sundays[index];
                    final dateLabel =
                        '${sunday.day.toString()} ${_arabicMonthName(sunday.month)} ${sunday.year}';
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        onTap: () => _openSundayPdf(sunday),
                        title: Text(dateLabel),
                        subtitle: Text('تحميل نشرة الأحد من الرابط الرسمي'),
                        trailing: Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NetworkPdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const NetworkPdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  State<NetworkPdfViewerScreen> createState() => _NetworkPdfViewerScreenState();
}

class _NetworkPdfViewerScreenState extends State<NetworkPdfViewerScreen> {
  PdfController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        _controller = PdfController(document: PdfDocument.openData(response.bodyBytes));
      } else {
        _error = 'لم يتم اضافته بعد';
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل PDF: $e';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 2,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : PdfView(
                    controller: _controller!,
                    scrollDirection: Axis.vertical,
                    pageSnapping: true,
                  ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

final List<Map<String, String>> prayers = [
    {
    'name': 'صلاة الغروب',
    'pdfPath': 'assets/prayers/4.pdf',
    'imagePath': 'assets/icon/app_icon.png',
  },
  {
    'name': 'صلاة النهوض من النوم',
    'pdfPath': 'assets/prayers/1.pdf',
    'imagePath': 'assets/icon/app_icon.png',
  },
  {
    'name': 'صلاة النوم الصغرى',
    'pdfPath': 'assets/prayers/5.pdf',
    'imagePath': 'assets/icon/app_icon.png',
  },
  {
    'name': 'كتاب خدمة القداس الإلهي',
    'pdfPath': 'assets/prayers/3.pdf',
    'imagePath': 'assets/icon/app_icon.png',
  },
  {
    'name': 'البراكليسي الصغير',
    'pdfPath': 'assets/prayers/7.pdf',
    'imagePath': 'assets/icon/app_icon.png',
  },
  {
    'name': 'خدمة صلاة السجدة',
    'pdfPath': 'assets/prayers/9.pdf',
    'imagePath': 'assets/icon/app_icon.png',
  },
  {
    'name': 'الأسبوع العظيم',
    'pdfPath': 'assets/prayers/8.pdf',
    'imagePath': 'assets/icon/app_icon.png',
  },
  {
    'name': 'صلاة النوم الكبرى ومديح السيّدة',
    'pdfPath': 'assets/prayers/6.pdf',
    'imagePath': 'assets/icon/app_icon.png',
  },
  {
    'name': 'صلاة السحر',
    'pdfPath': 'assets/prayers/2.pdf',
    'imagePath': 'assets/icon/app_icon.png',
  },

];

class PrayersScreen extends StatelessWidget {
  const PrayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الصلوات'), elevation: 2),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'صلوات الكنيسة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'عرض مجموعة الصلوات الرسمية بصيغة PDF للقراءة السهلة داخل التطبيق.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: prayers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final prayer = prayers[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(
                                title: prayer['name']!,
                                pdfPath: prayer['pdfPath']!,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  prayer['imagePath'] ?? 'assets/icon/app_icon.png',
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prayer['name']!,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'ملف PDF',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfPath;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfPath,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PdfController? _pdfController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  void _initializePdf() {
    try {
      _pdfController = PdfController(
        document: PdfDocument.openAsset(widget.pdfPath),
      );
    } catch (e) {
      debugPrint('Error loading PDF: $e');
      _pdfController = PdfController(
        document: PdfDocument.openAsset(widget.pdfPath),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title), centerTitle: true),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : PdfView(
                controller: _pdfController!,
                scrollDirection: Axis.vertical,
                pageSnapping: true,
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import '../services/media_service.dart';

class ChantsBooksScreen extends StatefulWidget {
  const ChantsBooksScreen({super.key});

  @override
  State<ChantsBooksScreen> createState() => _ChantsBooksScreenState();
}

class _ChantsBooksScreenState extends State<ChantsBooksScreen> {
  late Future<List<BookItem>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = MediaService.getBookItems();
  }

  Future<void> _openPdf(BookItem book) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          pdfUrl: book.pdfUrl,
          title: book.title,
          isNetwork: MediaService.isNetworkPath(book.pdfUrl),
        ),
      ),
    );
  }

  ImageProvider _coverImage(String coverUrl) {
    if (MediaService.isNetworkPath(coverUrl)) {
      return NetworkImage(coverUrl);
    }
    return AssetImage(coverUrl) as ImageProvider;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الكتب الإلكترونية'),
          elevation: 2,
        ),
        body: FutureBuilder<List<BookItem>>(
          future: _booksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'فشل تحميل قائمة الكتب. حاول مرة أخرى لاحقاً.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final books = snapshot.data ?? [];
            if (books.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد كتب متاحة حالياً.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => _openPdf(book),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              image: DecorationImage(
                                image: _coverImage(book.coverUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  book.author,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final bool isNetwork;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
    required this.isNetwork,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PdfController? _pdfController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      if (widget.isNetwork) {
        final response = await http.get(Uri.parse(widget.pdfUrl));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          _pdfController = PdfController(document: PdfDocument.openData(bytes));
        } else {
          _error = '??? ????? ??????. ??? ??????: ${response.statusCode}';
        }
      } else if (widget.pdfUrl.startsWith('assets/')) {
        // Bundled asset
        _pdfController = PdfController(document: PdfDocument.openAsset(widget.pdfUrl));
      } else {
        // Local file (cached from download service)
        _pdfController = PdfController(document: PdfDocument.openFile(widget.pdfUrl));
      }
    } catch (e) {
      _error = '??? ??? ??????: $e';
    }

    setState(() {
      _isLoading = false;
    });
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
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 2,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : PdfView(controller: _pdfController!),
      ),
    );
  }
}

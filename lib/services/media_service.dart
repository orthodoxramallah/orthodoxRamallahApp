import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class MediaType {
  static const String audio = 'audio';
  static const String video = 'video';
  static const String book = 'book';
}

class MediaItem {
  final String id;
  final String title;
  final String description;
  final String path;

  const MediaItem({
    required this.id,
    required this.title,
    required this.description,
    required this.path,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      path: MediaService.normalizeDropboxUrl(json['path'] as String),
    );
  }
}

class BookItem {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String pdfUrl;

  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.pdfUrl,
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    return BookItem(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? '',
      coverUrl: MediaService.normalizeDropboxUrl(json['coverUrl'] as String),
      pdfUrl: MediaService.normalizeDropboxUrl(json['pdfUrl'] as String),
    );
  }
}

class MediaService {
  // ✅ Raw GitHub URL — not the webpage URL (no /blob/)
  static const String _remoteCatalogUrl =
      'https://raw.githubusercontent.com/fadihanhan161296-ai/ChurchApp/main/media_catalog.json';
  static const String _localCatalogPath = 'assets/data/media_catalog.json';

  /// Converts a Dropbox shared link to a direct-download link.
  /// Leaves non-Dropbox URLs untouched.
  static String normalizeDropboxUrl(String url) {
    if (!url.contains('dropbox.com')) return url;

    if (url.contains('?dl=0')) {
      return url.replaceFirst('?dl=0', '?dl=1');
    }
    if (!url.contains('?dl=')) {
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}dl=1';
    }
    return url;
  }

  static Future<Map<String, dynamic>> _loadCatalogData() async {
    try {
      final response = await http
          .get(Uri.parse(_remoteCatalogUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final rawData = json.decode(response.body);
        if (rawData is Map<String, dynamic>) {
          return rawData;
        }
      }
    } catch (_) {
      // Fall back to local asset
    }
    return _loadLocalCatalog();
  }

  static Future<Map<String, dynamic>> _loadLocalCatalog() async {
    try {
      final jsonString = await rootBundle.loadString(_localCatalogPath);
      final rawData = json.decode(jsonString);
      if (rawData is Map<String, dynamic>) {
        return rawData;
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  static List<T> _parseItems<T>(
    List<dynamic>? rawItems,
    T Function(Map<String, dynamic>) builder,
  ) {
    if (rawItems == null) return <T>[];
    return rawItems.map((dynamic item) {
      if (item is Map<String, dynamic>) return builder(item);
      if (item is Map) return builder(Map<String, dynamic>.from(item));
      throw FormatException('Unexpected item type: ${item.runtimeType}');
    }).toList();
  }

  static Future<List<MediaItem>> getAudioItems() async {
    final catalog = await _loadCatalogData();
    return _parseItems<MediaItem>(
        catalog['audio'] as List<dynamic>?, MediaItem.fromJson);
  }

  static Future<List<MediaItem>> getVideoItems() async {
    final catalog = await _loadCatalogData();
    return _parseItems<MediaItem>(
        catalog['video'] as List<dynamic>?, MediaItem.fromJson);
  }

  static Future<List<BookItem>> getBookItems() async {
    final catalog = await _loadCatalogData();
    return _parseItems<BookItem>(
        catalog['books'] as List<dynamic>?, BookItem.fromJson);
  }

  static bool isNetworkPath(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }
}
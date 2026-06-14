import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ScheduleService {
  static const String _remoteCatalogUrl =
      'https://raw.githubusercontent.com/fadihanhan161296-ai/ChurchApp/main/schedules_catalog.json';

  static const Duration _cacheExpiration = Duration(minutes: 5);

  static const List<Map<String, String>> _fallbackSchedules = [];

  static Map<String, dynamic>? _cachedCatalog;
  static DateTime? _lastFetchTime;

  static bool get _isCacheExpired {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) > _cacheExpiration;
  }

  static Future<Map<String, dynamic>> _loadCatalog() async {
    if (_cachedCatalog != null && !_isCacheExpired) {
      return _cachedCatalog!;
    }

    try {
      final response = await http
          .get(Uri.parse(_remoteCatalogUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          _cachedCatalog = data;
          _lastFetchTime = DateTime.now();
          return data;
        }
      }
    } catch (e) {
      debugPrint('Error fetching catalog: $e');
    }

    return _cachedCatalog ?? {};
  }

  static Future<List<Map<String, String>>> getSchedules() async {
    try {
      final catalog = await _loadCatalog();
      final raw = catalog['schedules'] as List<dynamic>?;
      if (raw == null || raw.isEmpty) return _fallbackSchedules;
      return raw.map((item) => Map<String, String>.from(item as Map)).toList();
    } catch (e) {
      debugPrint('Error parsing schedules: $e');
      return _fallbackSchedules;
    }
  }

  static Future<List<String>> getAdvertisements() async {
    try {
      final catalog = await _loadCatalog();
      final raw = catalog['ads'] as List<dynamic>?;
      if (raw == null) return [];
      return raw.map((item) => item.toString()).toList();
    } catch (e) {
      debugPrint('Error parsing ads: $e');
      return [];
    }
  }

  static Future<List<Map<String, String>>> refreshSchedules() async {
    _cachedCatalog = null;
    _lastFetchTime = null;
    return getSchedules();
  }
}

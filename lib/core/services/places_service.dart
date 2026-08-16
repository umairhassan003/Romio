import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A place (city / town / landmark) returned by the autocomplete search.
class PlaceResult {
  /// Short label shown in the search bar, e.g. "Caracas".
  final String label;

  /// Full display name, e.g. "Caracas, Distrito Capital, Venezuela".
  final String fullName;
  final double latitude;
  final double longitude;

  const PlaceResult({
    required this.label,
    required this.fullName,
    required this.latitude,
    required this.longitude,
  });
}

/// Looks up places using the free OpenStreetMap Nominatim geocoder (no API key
/// required — the web admin uses the same service). Results are restricted to
/// Venezuela via `countrycodes=ve`.
class PlacesService {
  final http.Client _client;
  PlacesService({http.Client? client}) : _client = client ?? http.Client();

  static const String _base = 'https://nominatim.openstreetmap.org/search';

  /// Returns up to 6 Venezuelan places matching [query]. Empty for short
  /// queries or on any error (network/parse) — the caller shows an empty state.
  Future<List<PlaceResult>> searchVenezuela(String query) async {
    if (query.trim().length < 3) return [];
    try {
      final url = Uri.parse(
        '$_base?q=${Uri.encodeComponent(query)}'
        '&format=json&addressdetails=1&limit=6&countrycodes=ve',
      );
      final res = await _client.get(url, headers: {'User-Agent': 'RomioApp/1.0'});
      if (res.statusCode != 200) return [];

      final data = json.decode(res.body);
      if (data is! List) return [];

      return data
          .map((item) {
            final addr = (item['address'] is Map)
                ? item['address'] as Map
                : const {};
            final display = (item['display_name'] ?? '').toString();
            final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0;
            final lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0;
            final label = (addr['city'] ??
                    addr['town'] ??
                    addr['village'] ??
                    addr['county'] ??
                    addr['state'] ??
                    (display.isNotEmpty ? display.split(',').first : ''))
                .toString();
            return PlaceResult(
              label: label,
              fullName: display,
              latitude: lat,
              longitude: lon,
            );
          })
          .where((p) => p.latitude != 0 || p.longitude != 0)
          .toList();
    } catch (e) {
      debugPrint('PlacesService: search failed: $e');
      return [];
    }
  }
}

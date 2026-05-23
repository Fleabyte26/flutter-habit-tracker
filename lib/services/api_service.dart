import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _quoteBaseUrl = 'https://api.quotable.io';
  static const String _weatherBaseUrl = 'https://api.open-meteo.com/v1';

  // ─── Motivational Quotes ──────────────────────────────────

  // Fetch a random motivational quote
  static Future<Map<String, dynamic>> fetchRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse('$_quoteBaseUrl/random?tags=motivational,success,happiness'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'quote': data['content'],
          'author': data['author'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch quote: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Fetch multiple quotes by tag
  static Future<List<Map<String, dynamic>>> fetchQuotesByTag(String tag) async {
    try {
      final response = await http.get(
        Uri.parse('$_quoteBaseUrl/quotes?tags=$tag&limit=5'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((q) => {
          'quote': q['content'],
          'author': q['author'],
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ─── Weather ──────────────────────────────────────────────

  // Fetch current weather by latitude and longitude
  static Future<Map<String, dynamic>> fetchWeather({
    double latitude = 6.2442,
    double longitude = -75.5812,
  }) async {
    try {
      final url = Uri.parse(
        '$_weatherBaseUrl/forecast?latitude=$latitude&longitude=$longitude'
        '&current_weather=true&hourly=temperature_2m,relativehumidity_2m,windspeed_10m',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current_weather'];
        return {
          'success': true,
          'temperature': current['temperature'],
          'windspeed': current['windspeed'],
          'weathercode': current['weathercode'],
          'description': _getWeatherDescription(current['weathercode']),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch weather: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Convert weather code to human-readable description
  static String _getWeatherDescription(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  // ─── Habit Stats ──────────────────────────────────────────

  // Calculate habit completion stats from local data
  static Map<String, dynamic> calculateStats({
    required int totalHabits,
    required int completedToday,
    required int currentStreak,
    required List<String> completedDates,
  }) {
    final completionRate = totalHabits == 0
        ? 0.0
        : (completedToday / totalHabits) * 100;

    final last7Days = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      return completedDates.contains(dateStr);
    });

    final weeklyCompletions = last7Days.where((d) => d).length;

    return {
      'completionRate': completionRate.toStringAsFixed(1),
      'currentStreak': currentStreak,
      'weeklyCompletions': weeklyCompletions,
      'totalCompletions': completedDates.length,
    };
  }
}

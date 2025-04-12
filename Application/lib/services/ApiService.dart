import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  // Base URL for API
  static const String BASE_HOST = 'http://172.16.103.209:8000';
  static const String API_PREFIX = '/api';
  static String? _authToken;

  // Cache duration constants
  static const int DEFAULT_CACHE_DURATION_HOURS = 24;
  static const int DEFAULT_CACHE_DURATION_MINUTES = 0;

  // Default headers
  static Map<String, String> get defaultHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Set auth token
  static void setAuthToken(String token) {
    _authToken = token;
    // Lưu token vào SharedPreferences
    _saveTokenToPrefs(token);
  }

  // Lưu token vào SharedPreferences
  static Future<void> _saveTokenToPrefs(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('Auth token saved to SharedPreferences');
    } catch (e) {
      print('Error saving auth token: $e');
    }
  }

  // Lấy token từ SharedPreferences
  static Future<String?> getAuthToken() async {
    try {
      // Nếu đã có token trong memory, trả về luôn
      if (_authToken != null) {
        return _authToken;
      }

      // Nếu chưa có, thử lấy từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Nếu có token trong SharedPreferences, cập nhật biến _authToken
      if (token != null && token.isNotEmpty) {
        _authToken = token;
      }

      return token;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Clear auth token
  static void clearAuthToken() async {
    _authToken = null;
    // Xóa token từ SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      print('Error clearing auth token: $e');
    }
  }

  // Get full API URL for a resource
  static String getUrl(String resource) {
    return '$BASE_HOST$API_PREFIX$resource';
  }

  // Check internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Validate cache based on timestamp
  static Future<bool> isCacheValid(String key,
      {int durationHours = DEFAULT_CACHE_DURATION_HOURS,
      int durationMinutes = DEFAULT_CACHE_DURATION_MINUTES}) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('cache_timestamp_$key');
    if (timestamp == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheDurationMs =
        Duration(hours: durationHours, minutes: durationMinutes).inMilliseconds;
    return (now - timestamp) < cacheDurationMs;
  }

  // Save data to cache
  static Future<void> saveToCache(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
      await prefs.setInt(
          'cache_timestamp_$key', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  // Get data from cache
  static Future<dynamic> getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(key);

      if (cachedData != null) {
        return jsonDecode(cachedData);
      }
      return null;
    } catch (e) {
      print('Error getting from cache: $e');
      return null;
    }
  }

  // Clear specific cache entries
  static Future<void> clearCache(String keyPattern) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (var key in keys) {
        if (key.startsWith(keyPattern) ||
            key.startsWith('cache_timestamp_$keyPattern')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // HTTP GET with caching
  static Future<dynamic> getWithCache(
    String url, {
    Map<String, String>? headers,
    String cacheKey = '',
    bool forceRefresh = false,
    int cacheDuration = DEFAULT_CACHE_DURATION_HOURS,
    int cacheDurationMinutes = DEFAULT_CACHE_DURATION_MINUTES,
    Map<String, dynamic>? queryParams,
  }) async {
    // Use URL as cache key if no specific key provided
    final effectiveCacheKey = cacheKey.isEmpty ? url : cacheKey;

    // Try cache first if not forcing refresh
    if (!forceRefresh) {
      final isCacheValid = await ApiService.isCacheValid(effectiveCacheKey,
          durationHours: cacheDuration, durationMinutes: cacheDurationMinutes);
      if (isCacheValid) {
        final cachedData = await getFromCache(effectiveCacheKey);
        if (cachedData != null) {
          return cachedData;
        }
      }
    }

    // Check internet connection
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      // Try to use cache even if expired when offline
      final cachedData = await getFromCache(effectiveCacheKey);
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('No internet connection and no cached data available');
    }

    // Make API call
    try {
      // Build URL with query parameters if provided
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(
          queryParameters:
              queryParams.map((key, value) => MapEntry(key, value.toString())),
        );
      }

      final response = await http.get(
        uri,
        headers: headers ?? defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save to cache
        await saveToCache(effectiveCacheKey, data);
        return data;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } on SocketException {
      // If connection fails during API call, try to use cache
      final cachedData = await getFromCache(effectiveCacheKey);
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('Cannot connect to server and no cached data available');
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  // HTTP POST request
  static Future<dynamic> post(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String cacheKeyToInvalidate = '',
  }) async {
    // Check internet connection
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw Exception('No internet connection. Cannot perform this operation.');
    }

    try {
      print('POST request to: $url');
      print('Request body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers ?? defaultHeaders,
        body: jsonEncode(body),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Invalidate cache if needed
        if (cacheKeyToInvalidate.isNotEmpty) {
          await clearCache(cacheKeyToInvalidate);
        }
        return responseData;
      }
      // Xử lý response code 409 - Conflict
      else if (response.statusCode == 409) {
        // Trả về dữ liệu để xử lý ở client
        return {
          'success': false,
          'status_code': 409,
          'message': responseData['message'] ?? 'Resource conflict',
          'data': responseData
        };
      } else {
        throw Exception(responseData['message'] ??
            'Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // HTTP PUT request
  static Future<dynamic> put(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String cacheKeyToInvalidate = '',
  }) async {
    // Check internet connection
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw Exception('No internet connection. Cannot perform this operation.');
    }

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers ?? defaultHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Invalidate cache if needed
        if (cacheKeyToInvalidate.isNotEmpty) {
          await clearCache(cacheKeyToInvalidate);
        }
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // HTTP PATCH request
  static Future<dynamic> patch(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String cacheKeyToInvalidate = '',
  }) async {
    // Check internet connection
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw Exception('No internet connection. Cannot perform this operation.');
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers ?? defaultHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Invalidate cache if needed
        if (cacheKeyToInvalidate.isNotEmpty) {
          await clearCache(cacheKeyToInvalidate);
        }
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // HTTP DELETE request
  static Future<void> delete(
    String url, {
    Map<String, String>? headers,
    String cacheKeyToInvalidate = '',
  }) async {
    // Check internet connection
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw Exception('No internet connection. Cannot perform this operation.');
    }

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers ?? defaultHeaders,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete: ${response.statusCode}');
      }

      // Invalidate cache if needed
      if (cacheKeyToInvalidate.isNotEmpty) {
        await clearCache(cacheKeyToInvalidate);
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

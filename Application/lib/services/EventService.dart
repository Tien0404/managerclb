import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/ApiService.dart';

class EventApiService {
  // Base URL và cache keys
  static const String _resource = '/events';
  static String get baseUrl =>
      ApiService.BASE_HOST + ApiService.API_PREFIX + _resource;

  // Cache keys
  static const String EVENTS_CACHE_KEY = 'events_cache';
  static const String EVENT_DETAIL_CACHE_PREFIX = 'event_detail_';
  static const String CLUB_EVENTS_CACHE_PREFIX = 'club_events_';
  static const String SEARCH_EVENTS_CACHE_PREFIX = 'search_events_';

  // Cache duration
  static const int CACHE_DURATION_MINUTES = 1;

  // Kiểm tra kết nối internet
  static Future<bool> _hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Xác thực cache còn hạn dùng hay không (24 giờ)
  static bool _isCacheValid(String timestamp) {
    if (timestamp.isEmpty) return false;

    DateTime cacheTime = DateTime.parse(timestamp);
    DateTime now = DateTime.now();

    // Cache có hiệu lực trong 5 phút
    return now.difference(cacheTime).inMinutes < CACHE_DURATION_MINUTES;
  }

  // Lưu dữ liệu vào cache
  static Future<void> _saveToCache(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(key, jsonEncode(cacheData));
  }

  // Lấy dữ liệu từ cache
  static Future<dynamic> _getFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(key);

    if (cachedData != null) {
      final decodedData = jsonDecode(cachedData);
      if (_isCacheValid(decodedData['timestamp'])) {
        return decodedData['data'];
      }
    }
    return null;
  }

  // Lấy danh sách sự kiện với cache
  static Future<List<dynamic>> getEvents({bool forceRefresh = false}) async {
    try {
      // Add timestamp to prevent server caching
      final queryParams = {
        '_t': DateTime.now().millisecondsSinceEpoch.toString()
      };

      return await ApiService.getWithCache(
        baseUrl,
        cacheKey: EVENTS_CACHE_KEY,
        forceRefresh: forceRefresh,
        queryParams: queryParams,
        cacheDuration: 0,
        cacheDurationMinutes: CACHE_DURATION_MINUTES,
      );
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  // Tạo sự kiện mới
  static Future<dynamic> createEvent(Map<String, dynamic> eventData) async {
    try {
      final result = await ApiService.post(
        baseUrl,
        body: eventData,
        cacheKeyToInvalidate: EVENTS_CACHE_KEY,
      );

      // Xóa cache tìm kiếm
      await ApiService.clearCache(SEARCH_EVENTS_CACHE_PREFIX);
      // Also clear club events cache as this might affect club events lists
      await ApiService.clearCache(CLUB_EVENTS_CACHE_PREFIX);

      return result;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  // Lấy chi tiết sự kiện với cache
  static Future<dynamic> getEventById(int id,
      {bool forceRefresh = false}) async {
    final cacheKey = EVENT_DETAIL_CACHE_PREFIX + id.toString();

    try {
      // Add timestamp to prevent server caching
      final queryParams = {
        '_t': DateTime.now().millisecondsSinceEpoch.toString()
      };

      return await ApiService.getWithCache(
        '$baseUrl/$id',
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        queryParams: queryParams,
        cacheDuration: 0,
        cacheDurationMinutes: CACHE_DURATION_MINUTES,
      );
    } catch (e) {
      throw Exception('Failed to load event details: $e');
    }
  }

  // Lấy danh sách sự kiện theo câu lạc bộ
  static Future<List<dynamic>> getClubEvents(int clubId,
      {bool forceRefresh = false}) async {
    final cacheKey = CLUB_EVENTS_CACHE_PREFIX + clubId.toString();

    try {
      // Add timestamp to prevent server caching
      final queryParams = {
        '_t': DateTime.now().millisecondsSinceEpoch.toString()
      };

      return await ApiService.getWithCache(
        '$baseUrl/club/$clubId',
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        queryParams: queryParams,
        cacheDuration: 0,
        cacheDurationMinutes: CACHE_DURATION_MINUTES,
      );
    } catch (e) {
      // For 404, return empty list
      if (e.toString().contains('404')) {
        return [];
      }
      throw Exception('Failed to load club events: $e');
    }
  }

  // Cập nhật sự kiện
  static Future<dynamic> updateEvent(
      int id, Map<String, dynamic> eventData) async {
    try {
      final result = await ApiService.put(
        '$baseUrl/$id',
        body: eventData,
        cacheKeyToInvalidate: EVENTS_CACHE_KEY,
      );

      // Also invalidate specific event cache
      await ApiService.clearCache(EVENT_DETAIL_CACHE_PREFIX + id.toString());
      // Xóa cache tìm kiếm
      await ApiService.clearCache(SEARCH_EVENTS_CACHE_PREFIX);
      // Also clear club events cache as this might affect club events lists
      await ApiService.clearCache(CLUB_EVENTS_CACHE_PREFIX);

      return result;
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Xóa sự kiện
  static Future<void> deleteEvent(int id) async {
    try {
      await ApiService.delete(
        '$baseUrl/$id',
        cacheKeyToInvalidate: EVENTS_CACHE_KEY,
      );

      // Also invalidate specific event cache
      await ApiService.clearCache(EVENT_DETAIL_CACHE_PREFIX + id.toString());
      // Xóa cache tìm kiếm
      await ApiService.clearCache(SEARCH_EVENTS_CACHE_PREFIX);
      // Also clear club events cache as this might affect club events lists
      await ApiService.clearCache(CLUB_EVENTS_CACHE_PREFIX);
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Xóa tất cả cache liên quan đến sự kiện
  static Future<void> clearAllEventCache() async {
    await ApiService.clearCache(EVENTS_CACHE_KEY);
    await ApiService.clearCache(EVENT_DETAIL_CACHE_PREFIX);
    await ApiService.clearCache(CLUB_EVENTS_CACHE_PREFIX);
    await ApiService.clearCache(SEARCH_EVENTS_CACHE_PREFIX);
  }

  // Tìm kiếm sự kiện với nhiều tiêu chí
  static Future<List<dynamic>> searchEvents({
    String? name,
    int? clubId,
    int? categoryId,
    String? startDateFrom,
    String? startDateTo,
    String? endDateFrom,
    String? endDateTo,
    String? location,
    String? status,
    int? maxParticipants,
    int? minParticipants,
    String? content,
    String? sortBy,
    String? sortDirection,
    int? perPage,
    bool paginate = true,
    bool forceRefresh = false,
  }) async {
    // Xây dựng query parameters
    Map<String, dynamic> queryParams = {};

    if (name != null) queryParams['name'] = name;
    if (clubId != null) queryParams['club_id'] = clubId.toString();
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (startDateFrom != null) queryParams['start_date_from'] = startDateFrom;
    if (startDateTo != null) queryParams['start_date_to'] = startDateTo;
    if (endDateFrom != null) queryParams['end_date_from'] = endDateFrom;
    if (endDateTo != null) queryParams['end_date_to'] = endDateTo;
    if (location != null) queryParams['location'] = location;
    if (status != null) queryParams['status'] = status;
    if (maxParticipants != null)
      queryParams['max_participants'] = maxParticipants.toString();
    if (minParticipants != null)
      queryParams['min_participants'] = minParticipants.toString();
    if (content != null) queryParams['content'] = content;
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (sortDirection != null) queryParams['sort_direction'] = sortDirection;
    if (perPage != null) queryParams['per_page'] = perPage.toString();
    if (!paginate) queryParams['paginate'] = 'false';

    // Add timestamp to prevent server caching
    queryParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();

    // Tạo Uri với các tham số tìm kiếm
    final uri =
        Uri.parse('$baseUrl/search').replace(queryParameters: queryParams);

    // Tạo cache key dựa trên URI
    final cacheKey =
        SEARCH_EVENTS_CACHE_PREFIX + uri.toString().hashCode.toString();

    try {
      return await ApiService.getWithCache(
        uri.toString(),
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        cacheDuration: 0,
        cacheDurationMinutes: CACHE_DURATION_MINUTES,
      );
    } catch (e) {
      if (e.toString().contains('404')) {
        return [];
      }
      throw Exception('Không thể tìm kiếm sự kiện: $e');
    }
  }
}

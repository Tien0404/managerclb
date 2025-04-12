import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/ApiService.dart';

class BlogApi {
  static const String _resource = '/blogs';
  static String get baseUrl =>
      ApiService.BASE_HOST + ApiService.API_PREFIX + _resource;

  // Cache configuration
  static const String BLOGS_CACHE_KEY = 'blogs_cache';
  static const String BLOG_DETAIL_PREFIX = 'blog_detail_';
  static const int CACHE_DURATION_MINUTES = 1;

  // Cache danh sách clubs và categories
  static Map<int, String> _clubNames = {};
  static Map<int, String> _categoryNames = {};

  // Lấy danh sách blog
  static Future<List<dynamic>> fetchBlogs({bool forceRefresh = false}) async {
    print('Fetching URL: $baseUrl');

    // Add timestamp to prevent server caching
    final queryParams = {
      '_t': DateTime.now().millisecondsSinceEpoch.toString()
    };

    final response = await ApiService.getWithCache(
      baseUrl,
      cacheKey: BLOGS_CACHE_KEY,
      forceRefresh: forceRefresh,
      queryParams: queryParams,
      cacheDuration: 0,
      cacheDurationMinutes: CACHE_DURATION_MINUTES,
    );

    if (response == null) {
      print('Response is null');
      return [];
    }

    // In ra để debug
    print(
        'Số lượng blog đã tải: ${response is List ? response.length : response['data']?.length ?? 0}');
    if (response is List && response.isNotEmpty) {
      print('Blog đầu tiên: ${response[0]}');
    } else if (response is Map &&
        response['data'] is List &&
        response['data'].isNotEmpty) {
      print('Blog đầu tiên: ${response['data'][0]}');
    }

    // Kiểm tra nếu response là Map và có key 'data'
    if (response is Map && response.containsKey('data')) {
      if (response['data'] is List) {
        return List<dynamic>.from(response['data']);
      }
      print('Response data is not a List: ${response['data'].runtimeType}');
      return [];
    }

    // Nếu response trực tiếp là List
    if (response is List) {
      return List<dynamic>.from(response);
    }

    print(
        'Response is neither Map with data nor List: ${response.runtimeType}');
    return [];
  }

  // Lấy chi tiết blog
  static Future<Map<String, dynamic>> getBlog(int id,
      {bool forceRefresh = false}) async {
    print('Fetching URL: $baseUrl/$id');

    // Add timestamp to prevent server caching
    final queryParams = {
      '_t': DateTime.now().millisecondsSinceEpoch.toString()
    };

    final response = await ApiService.getWithCache(
      "$baseUrl/$id",
      cacheKey: "$BLOG_DETAIL_PREFIX$id",
      forceRefresh: forceRefresh,
      queryParams: queryParams,
      cacheDuration: 0,
      cacheDurationMinutes: CACHE_DURATION_MINUTES,
    );

    if (response == null) {
      throw Exception('Không thể tải chi tiết bài viết');
    }

    // Kiểm tra nếu response là Map và có key 'data'
    if (response is Map) {
      Map<String, dynamic> typedMap;
      if (response.containsKey('data')) {
        typedMap = Map<String, dynamic>.from(response['data']);
      } else {
        typedMap = Map<String, dynamic>.from(response);
      }
      return typedMap;
    }

    throw Exception('Dữ liệu không đúng định dạng');
  }

  // Tạo blog mới
  static Future<void> createBlog(Map<String, dynamic> blogData) async {
    await ApiService.post(
      baseUrl,
      body: blogData,
      cacheKeyToInvalidate: BLOGS_CACHE_KEY,
    );
  }

  // Cập nhật blog
  static Future<void> updateBlog(int id, Map<String, dynamic> blogData) async {
    await ApiService.patch(
      "$baseUrl/$id",
      body: blogData,
      cacheKeyToInvalidate: BLOGS_CACHE_KEY,
    );

    // Also invalidate specific blog cache
    await ApiService.clearCache("$BLOG_DETAIL_PREFIX$id");
  }

  // Xóa blog
  static Future<void> deleteBlog(int id) async {
    await ApiService.delete(
      "$baseUrl/$id",
      cacheKeyToInvalidate: BLOGS_CACHE_KEY,
    );

    // Also invalidate specific blog cache
    await ApiService.clearCache("$BLOG_DETAIL_PREFIX$id");
  }

  // Clear all blog cache
  static Future<void> clearCache() async {
    await ApiService.clearCache(BLOGS_CACHE_KEY);
    await ApiService.clearCache(BLOG_DETAIL_PREFIX);
  }

  // Lấy tên CLB từ ID
  static Future<String> getClubName(int clubId) async {
    // Kiểm tra cache trước
    if (_clubNames.containsKey(clubId)) {
      return _clubNames[clubId] ?? "CLB $clubId";
    }

    try {
      final clubUrl =
          ApiService.BASE_HOST + ApiService.API_PREFIX + '/clubs/$clubId';

      // Add timestamp to prevent server caching
      final queryParams = {
        '_t': DateTime.now().millisecondsSinceEpoch.toString()
      };

      final club = await ApiService.getWithCache(
        clubUrl,
        queryParams: queryParams,
        cacheDuration: 0,
        cacheDurationMinutes: CACHE_DURATION_MINUTES,
      );

      if (club != null && club['name'] != null) {
        _clubNames[clubId] = club['name'];
        return club['name'];
      }
    } catch (e) {
      print('Không thể lấy thông tin CLB $clubId: $e');
    }

    return "CLB $clubId";
  }

  // Lấy tên category từ ID
  static Future<String> getCategoryName(int categoryId) async {
    // Kiểm tra cache trước
    if (_categoryNames.containsKey(categoryId)) {
      return _categoryNames[categoryId] ?? "Danh mục $categoryId";
    }

    try {
      final categoryUrl = ApiService.BASE_HOST +
          ApiService.API_PREFIX +
          '/categories/$categoryId';

      // Add timestamp to prevent server caching
      final queryParams = {
        '_t': DateTime.now().millisecondsSinceEpoch.toString()
      };

      final category = await ApiService.getWithCache(
        categoryUrl,
        queryParams: queryParams,
        cacheDuration: 0,
        cacheDurationMinutes: CACHE_DURATION_MINUTES,
      );

      if (category != null && category['name'] != null) {
        _categoryNames[categoryId] = category['name'];
        return category['name'];
      }
    } catch (e) {
      print('Không thể lấy thông tin category $categoryId: $e');
    }

    return "Danh mục $categoryId";
  }
}

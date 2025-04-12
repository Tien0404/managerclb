import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/ApiService.dart';

class CategoryService {
  // Base URL và cache keys
  static const String _resource = '/categories';
  static String get baseUrl =>
      ApiService.BASE_HOST + ApiService.API_PREFIX + _resource;

  static const String CATEGORIES_CACHE_KEY = 'categories_cache';
  static const String CATEGORY_DETAIL_PREFIX = 'category_detail_';
  static const int CACHE_DURATION_MINUTES = 5;

  // Lấy danh sách categories với caching
  Future<List<dynamic>> getCategories({bool forceRefresh = false}) async {
    try {
      // Add timestamp to prevent server caching
      final queryParams = {
        '_t': DateTime.now().millisecondsSinceEpoch.toString()
      };

      return await ApiService.getWithCache(
        baseUrl,
        cacheKey: CATEGORIES_CACHE_KEY,
        forceRefresh: forceRefresh,
        queryParams: queryParams,
        cacheDuration: 0,
        cacheDurationMinutes: CACHE_DURATION_MINUTES,
      );
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Lấy chi tiết category theo ID
  Future<dynamic> getCategory(String categoryId,
      {bool forceRefresh = false}) async {
    final cacheKey = '$CATEGORY_DETAIL_PREFIX$categoryId';

    try {
      // Add timestamp to prevent server caching
      final queryParams = {
        '_t': DateTime.now().millisecondsSinceEpoch.toString()
      };

      return await ApiService.getWithCache(
        '$baseUrl/$categoryId',
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        queryParams: queryParams,
        cacheDuration: 0,
        cacheDurationMinutes: CACHE_DURATION_MINUTES,
      );
    } catch (e) {
      throw Exception('Error fetching category: $e');
    }
  }

  // Xóa toàn bộ cache
  Future<void> clearCache() async {
    await ApiService.clearCache(CATEGORIES_CACHE_KEY);
    await ApiService.clearCache(CATEGORY_DETAIL_PREFIX);
  }
}

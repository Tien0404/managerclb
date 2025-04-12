import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/ApiService.dart';

class ClubService {
  // Base URL và cache keys
  static const String _resource = '/clubs';
  static String get baseUrl =>
      ApiService.BASE_HOST + ApiService.API_PREFIX + _resource;

  // Keys cho cache
  static const String CLUBS_CACHE_KEY = 'clubs_cache';
  static const String CLUB_DETAIL_PREFIX = 'club_detail_';
  static const String CACHE_TIMESTAMP_PREFIX = 'cache_timestamp_';
  static const int CACHE_DURATION_HOURS = 0;
  static const int CACHE_DURATION_MINUTES = 1;

  // Headers mặc định (có thể thêm authentication token nếu cần)
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Kiểm tra kết nối internet
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Kiểm tra cache có còn hiệu lực
  Future<bool> _isCacheValid(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('$CACHE_TIMESTAMP_PREFIX$key');
    if (timestamp == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheDuration = Duration(hours: CACHE_DURATION_HOURS).inMilliseconds;
    return (now - timestamp) < cacheDuration;
  }

  // Lưu dữ liệu vào cache
  Future<void> _saveToCache(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
      await prefs.setInt(
          '$CACHE_TIMESTAMP_PREFIX$key', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  // Lấy dữ liệu từ cache
  Future<dynamic> _getFromCache(String key) async {
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

  // Lấy danh sách clubs với caching
  Future<List<dynamic>> getClubs({
    bool forceRefresh = false,
    Map<String, dynamic>? params,
  }) async {
    // Tạo cache key riêng cho các bộ lọc khác nhau
    String cacheKey = CLUBS_CACHE_KEY;
    if (params != null && params.isNotEmpty) {
      final paramString =
          params.entries.map((e) => '${e.key}=${e.value}').join('_');
      cacheKey = '${CLUBS_CACHE_KEY}_$paramString';
    }

    try {
      // Thêm timestamp vào query params để đảm bảo dữ liệu luôn mới
      Map<String, dynamic> finalParams = params != null
          ? Map<String, dynamic>.from(params)
          : <String, dynamic>{};

      // Thêm timestamp để đảm bảo không lấy dữ liệu từ cache của API server
      finalParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();

      List<dynamic> clubs = await ApiService.getWithCache(
        baseUrl,
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        queryParams: finalParams,
        cacheDuration: CACHE_DURATION_MINUTES,
      );

      // Filter clubs by status - only show active clubs, exclude pending ones
      clubs = clubs.where((club) {
        // Get the status - if status is not specified, default to showing the club
        final status = club['status']?.toString().toLowerCase() ?? '';
        // Only include clubs that have status='active', exclude 'pending'
        return status == 'active' || (status != 'pending' && status != '');
      }).toList();

      return clubs;
    } catch (e) {
      throw Exception('Error fetching clubs: $e');
    }
  }

  // Lấy chi tiết club với caching
  Future<dynamic> getClub(String clubId, {bool forceRefresh = false}) async {
    final cacheKey = '$CLUB_DETAIL_PREFIX$clubId';

    try {
      // Thêm timestamp để đảm bảo không lấy dữ liệu từ cache của API server
      final queryParams = {
        '_t': DateTime.now().millisecondsSinceEpoch.toString()
      };

      return await ApiService.getWithCache(
        '$baseUrl/$clubId',
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        queryParams: queryParams,
        cacheDuration: 0,
        cacheDurationMinutes: CACHE_DURATION_MINUTES,
      );
    } catch (e) {
      throw Exception('Error fetching club: $e');
    }
  }

  // Tạo club mới
  Future<dynamic> createClub({
    required int userId,
    required int categoryId,
    required String name,
    String? contactEmail,
  }) async {
    try {
      final body = {
        'user_id': userId,
        'category_id': categoryId,
        'name': name,
        if (contactEmail != null) 'contact_email': contactEmail,
      };

      final response = await ApiService.post(
        baseUrl,
        body: body,
        cacheKeyToInvalidate: CLUBS_CACHE_KEY,
      );

      return response;
    } catch (e) {
      throw Exception('Error creating club: $e');
    }
  }

  // Cập nhật club
  Future<dynamic> updateClub(
    String clubId, {
    int? userId,
    int? categoryId,
    String? name,
    String? description,
    String? contactEmail,
    String? contactPhone,
    String? contactAddress,
    String? province,
    String? facebookLink,
    String? zaloLink,
    String? status,
  }) async {
    try {
      final body = {
        if (userId != null) 'user_id': userId,
        if (categoryId != null) 'category_id': categoryId,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (contactEmail != null) 'contact_email': contactEmail,
        if (contactPhone != null) 'contact_phone': contactPhone,
        if (contactAddress != null) 'contact_address': contactAddress,
        if (province != null) 'province': province,
        if (facebookLink != null) 'facebook_link': facebookLink,
        if (zaloLink != null) 'zalo_link': zaloLink,
        if (status != null) 'status': status,
      };

      final response = await ApiService.patch(
        '$baseUrl/$clubId',
        body: body,
        cacheKeyToInvalidate: CLUBS_CACHE_KEY,
      );

      // Also invalidate the specific club cache
      await ApiService.clearCache('$CLUB_DETAIL_PREFIX$clubId');

      return response;
    } catch (e) {
      throw Exception('Error updating club: $e');
    }
  }

  // Xóa club
  Future<void> deleteClub(String clubId) async {
    try {
      await ApiService.delete(
        '$baseUrl/$clubId',
        cacheKeyToInvalidate: CLUBS_CACHE_KEY,
      );

      // Also clear specific club cache
      await ApiService.clearCache('$CLUB_DETAIL_PREFIX$clubId');
    } catch (e) {
      throw Exception('Error deleting club: $e');
    }
  }

  // Xóa toàn bộ cache
  Future<void> clearCache() async {
    await ApiService.clearCache(CLUBS_CACHE_KEY);
    await ApiService.clearCache(CLUB_DETAIL_PREFIX);
  }

  // Tìm kiếm clubs với các tiêu chí lọc
  Future<List<dynamic>> searchClubs({
    String? name,
    int? userId,
    int? categoryId,
    String? description,
    int? minMembers,
    int? maxMembers,
    String? contactEmail,
    String? contactPhone,
    String? contactAddress,
    String? province,
    String? status,
    List<String>? statuses,
    String? sortBy,
    String? sortDirection,
    int? perPage,
    bool? paginate,
    bool forceRefresh = false,
  }) async {
    // Xây dựng params từ các tham số
    Map<String, dynamic> params = {};

    if (name != null) params['name'] = name;
    if (userId != null) params['user_id'] = userId;
    if (categoryId != null) params['category_id'] = categoryId;
    if (description != null) params['description'] = description;
    if (minMembers != null) params['min_members'] = minMembers;
    if (maxMembers != null) params['max_members'] = maxMembers;
    if (contactEmail != null) params['contact_email'] = contactEmail;
    if (contactPhone != null) params['contact_phone'] = contactPhone;

    // Kiểm tra xem contactAddress có phải là số trang không
    // Đây là giải pháp tạm thời vì API không có tham số page
    if (contactAddress != null) {
      // Nếu đây là số, sử dụng làm tham số page
      if (int.tryParse(contactAddress) != null) {
        params['page'] = contactAddress;
      } else {
        // Nếu không phải số, sử dụng như địa chỉ liên hệ thông thường
        params['contact_address'] = contactAddress;
      }
    }

    if (province != null) params['province'] = province;

    // Nếu không có status được truyền vào, mặc định là lọc theo 'active'
    if (status != null) {
      params['status'] = status;
    } else {
      // Mặc định chỉ lấy các club có status là 'active'
      params['status'] = 'active';
    }

    if (statuses != null && statuses.isNotEmpty)
      params['statuses'] = statuses.join(',');
    if (sortBy != null) params['sort_by'] = sortBy;
    if (sortDirection != null) params['sort_direction'] = sortDirection;
    if (perPage != null) params['per_page'] = perPage;
    if (paginate != null) params['paginate'] = paginate.toString();

    // Thêm timestamp để đảm bảo không lấy dữ liệu từ cache của API server
    params['_t'] = DateTime.now().millisecondsSinceEpoch.toString();

    // Tạo cache key riêng cho các bộ lọc khác nhau
    String cacheKey = 'search_clubs_cache';
    if (params.isNotEmpty) {
      final paramString =
          params.entries.map((e) => '${e.key}=${e.value}').join('_');
      cacheKey = '${cacheKey}_$paramString';
    }

    try {
      print('Calling club search API with params: $params');
      dynamic response = await ApiService.getWithCache(
        '$baseUrl/search',
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        queryParams: params,
        cacheDuration: 0,
        cacheDurationMinutes: CACHE_DURATION_MINUTES,
      );

      // Kiểm tra xem response có phải là Map không (có cấu trúc phân trang)
      if (response is Map) {
        // Nếu response có trường 'data', trả về mảng từ trường đó
        if (response.containsKey('data')) {
          List<dynamic> clubs = response['data'] as List<dynamic>;

          // Nếu người dùng đã chỉ định status, không cần lọc thêm
          if (status == null && statuses == null) {
            // Lọc lại để đảm bảo không có club nào có status='pending'
            clubs = clubs.where((club) {
              final clubStatus = club['status']?.toString().toLowerCase() ?? '';
              return clubStatus != 'pending';
            }).toList();
          }

          return clubs;
        }

        // Nếu không có trường 'data', chuyển đổi các giá trị thành list
        if (response.isNotEmpty) {
          return response.values.where((v) => v is List).first as List<dynamic>;
        }

        // Trả về danh sách rỗng nếu không tìm thấy dữ liệu
        return [];
      }

      // Nếu response đã là List, trả về trực tiếp
      if (response is List) {
        return response;
      }

      // Trường hợp khác, trả về danh sách rỗng
      return [];
    } catch (e) {
      print('Error searching clubs: $e');
      throw Exception('Error searching clubs: $e');
    }
  }
}

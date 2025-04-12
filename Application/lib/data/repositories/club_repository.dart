import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import '../../services/ClubService.dart';
import '../../services/CategoryService.dart';
import '../../utils/image_utils.dart';

class ClubRepository {
  final ClubService _clubService = ClubService();
  final CategoryService _categoryService = CategoryService();

  // Cache cho danh mục
  Map<String, String> _categoryCache = {};
  bool _categoriesLoaded = false;

  // Hàm để tải trước danh mục và lưu cache
  Future<void> _loadCategories() async {
    if (!_categoriesLoaded) {
      try {
        final categories = await _categoryService.getCategories();
        for (var category in categories) {
          if (category != null &&
              category['id'] != null &&
              category['name'] != null) {
            _categoryCache[category['id'].toString()] =
                category['name'].toString();
          }
        }
        _categoriesLoaded = true;
        developer.log('Categories loaded successfully', name: 'ClubRepository');
      } catch (e) {
        developer.log('Error loading categories: $e', name: 'ClubRepository');
      }
    }
  }

  // Hàm lấy tên danh mục từ ID
  Future<String> _getCategoryNameById(String? categoryId) async {
    if (categoryId == null) return 'Không xác định';

    await _loadCategories();

    // Trả về tên danh mục từ cache nếu có
    if (_categoryCache.containsKey(categoryId)) {
      return _categoryCache[categoryId]!;
    }

    // Nếu không có trong cache, thử lấy trực tiếp
    try {
      final category = await _categoryService.getCategory(categoryId);
      if (category != null && category['name'] != null) {
        _categoryCache[categoryId] = category['name'].toString();
        return category['name'].toString();
      }
    } catch (e) {
      print('Lỗi khi lấy chi tiết danh mục: $e');
    }

    return 'Danh mục #$categoryId';
  }

  // Lấy danh sách câu lạc bộ
  Future<List<Map<String, dynamic>>> getClubs({
    int page = 1,
    int limit = 10,
    String? categoryId,
    bool forceRefresh = false,
  }) async {
    try {
      // Tải trước danh mục nếu cần
      await _loadCategories();

      // Gọi service để lấy dữ liệu từ API hoặc cache
      final Map<String, dynamic> params = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Add category filter if provided
      if (categoryId != null) {
        params['category_id'] = categoryId;
      }

      developer.log('Fetching clubs with params: $params',
          name: 'ClubRepository');
      final clubs = await _clubService.getClubs(
        params: params,
        forceRefresh: forceRefresh,
      );

      // Transform the data
      final transformedClubs = clubs.map((club) {
        // Get category name
        String categoryName = 'Chưa phân loại';
        if (club['category'] != null) {
          if (club['category'] is Map) {
            categoryName =
                club['category']['name']?.toString() ?? 'Chưa phân loại';
          } else if (club['category'] is String) {
            categoryName = club['category'];
          }
        } else if (club['category_id'] != null &&
            _categoryCache.containsKey(club['category_id'].toString())) {
          categoryName = _categoryCache[club['category_id'].toString()]!;
        }

        // Get image URL
        final imageUrl =
            ImageUtils.getClubImageUrl(club) ?? 'assets/images/default.png';

        return {
          'id': club['id']?.toString() ?? '0',
          'name': club['name']?.toString() ?? 'No Title',
          'description': club['description']?.toString() ?? 'No Description',
          'contact_address': club['contact_address']?.toString(),
          'province': club['province']?.toString(),
          'member_count': club['member_count']?.toString() ?? '0',
          'category': categoryName,
          'category_id': club['category_id']?.toString(),
          'background_images': club['background_images'],
          'logo': club['logo'],
          'imageUrl': imageUrl,
          'tags': club['tags'] ?? [],
        };
      }).toList();

      developer.log('Transformed ${transformedClubs.length} clubs',
          name: 'ClubRepository');
      return transformedClubs;
    } catch (e) {
      developer.log('Error fetching clubs: $e', name: 'ClubRepository');
      throw Exception('Error fetching clubs: $e');
    }
  }

  // Hàm hỗ trợ để lấy URL hình ảnh từ dữ liệu trả về
  String _getImageUrl(dynamic club) {
    // Sử dụng ImageUtils.getClubImageUrl để lấy URL hình ảnh
    return ImageUtils.getClubImageUrl(club) ?? 'assets/images/default.png';
  }

  Future<Map<String, dynamic>?> getClubById(String clubId,
      {bool forceRefresh = false}) async {
    try {
      // Tải trước danh mục
      await _loadCategories();

      // Sử dụng ClubService thay vì gọi trực tiếp đến API
      final club =
          await _clubService.getClub(clubId, forceRefresh: forceRefresh);

      if (club != null) {
        // Xử lý trường hợp category là một đối tượng
        String categoryName = 'Chưa phân loại';
        String? categoryId;

        if (club['category'] != null) {
          if (club['category'] is Map) {
            categoryName =
                club['category']['name']?.toString() ?? 'Chưa phân loại';
            categoryId = club['category']['id']?.toString();
          } else {
            categoryName = club['category'].toString();
          }
        }

        // Nếu có category_id, lấy tên danh mục từ cache
        if (club['category_id'] != null) {
          categoryId = club['category_id'].toString();
          if (_categoryCache.containsKey(categoryId)) {
            categoryName = _categoryCache[categoryId]!;
          }
        }

        // Tính toán số sự kiện một cách an toàn
        String eventsCount = '0';
        if (club['events'] != null) {
          if (club['events'] is List) {
            eventsCount = (club['events'] as List).length.toString();
          } else if (club['events'] is int) {
            eventsCount = club['events'].toString();
          }
        }

        // Xử lý hình ảnh sử dụng ImageUtils
        String imageUrl =
            ImageUtils.getClubImageUrl(club) ?? 'assets/images/default.png';

        // Trả về dữ liệu đã được biến đổi
        return {
          'id': club['id']?.toString() ?? '0',
          'title': club['name']?.toString() ?? 'No Title',
          'name': club['name']?.toString() ?? 'No Title',
          'description': club['description']?.toString() ?? 'No Description',
          'category': categoryName,
          'category_id': categoryId,
          'location': club['province']?.toString() ??
              club['contact_address']?.toString() ??
              'Unknown Location',
          'members': club['member_count']?.toString() ?? '0',
          'members_count': club['member_count']?.toString() ?? '0',
          'member_count': club['member_count']?.toString() ?? '0',
          'events': club['events'] ?? [],
          'events_count': eventsCount,
          'imageUrl': imageUrl,
          'backgroundImages': club['background_images'],
        };
      } else {
        throw Exception('Failed to load club details: Club not found');
      }
    } catch (e) {
      throw Exception('Error fetching club details: $e');
    }
  }

  Future<Map<String, dynamic>> createClub({
    required int userId,
    required int categoryId,
    required String name,
    String? contactEmail,
  }) async {
    try {
      final newClub = await _clubService.createClub(
        userId: userId,
        categoryId: categoryId,
        name: name,
        contactEmail: contactEmail,
      );
      return {
        'id': newClub['id']?.toString() ?? '0',
        'title': newClub['name']?.toString() ?? 'No Title',
        'description': newClub['description']?.toString() ?? 'No Description',
        'location': newClub['province']?.toString() ?? 'Unknown Location',
        'members': newClub['members']?.toString() ?? '0',
        'imageUrl':
            ImageUtils.getClubImageUrl(newClub) ?? 'assets/images/default.png',
      };
    } catch (e) {
      throw Exception('Failed to create club: $e');
    }
  }

  Future<Map<String, dynamic>> updateClub(
    String clubId, {
    int? userId,
    int? categoryId,
    String? name,
    String? description,
    String? contactEmail,
  }) async {
    try {
      final updatedClub = await _clubService.updateClub(
        clubId,
        userId: userId,
        categoryId: categoryId,
        name: name,
        description: description,
        contactEmail: contactEmail,
      );
      return {
        'id': updatedClub['id']?.toString() ?? '0',
        'title': updatedClub['name']?.toString() ?? 'No Title',
        'description':
            updatedClub['description']?.toString() ?? 'No Description',
        'location': updatedClub['province']?.toString() ?? 'Unknown Location',
        'members': updatedClub['members']?.toString() ?? '0',
        'imageUrl': ImageUtils.getClubImageUrl(updatedClub) ??
            'assets/images/default.png',
      };
    } catch (e) {
      throw Exception('Failed to update club: $e');
    }
  }

  Future<void> deleteClub(String clubId) async {
    try {
      await _clubService.deleteClub(clubId);
    } catch (e) {
      throw Exception('Failed to delete club: $e');
    }
  }
}

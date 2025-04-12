import 'dart:convert';
import '../../services/CategoryService.dart';

class CategoryRepository {
  final CategoryService _categoryService = CategoryService();

  // Lấy tất cả danh mục
  Future<List<Map<String, dynamic>>> getCategories(
      {bool forceRefresh = false}) async {
    try {
      // Gọi service để lấy dữ liệu từ API hoặc cache
      final categories =
          await _categoryService.getCategories(forceRefresh: forceRefresh);

      // Chuyển đổi dữ liệu thành định dạng phù hợp cho UI
      return categories.map<Map<String, dynamic>>((category) {
        return {
          'id': category['id'],
          'name': category['name'] ?? 'Không có tên',
          'description': category['description'] ?? 'Không có mô tả',
          'icon': _getCategoryIcon(category['name'] ?? ''),
          'club_count': category['clubs']?.length?.toString() ?? '0',
        };
      }).toList();
    } catch (e) {
      print('Lỗi trong getCategories: $e');
      throw Exception('Không thể lấy danh sách danh mục: $e');
    }
  }

  // Lấy danh mục theo ID
  Future<Map<String, dynamic>?> getCategoryById(String categoryId,
      {bool forceRefresh = false}) async {
    try {
      final category = await _categoryService.getCategory(categoryId,
          forceRefresh: forceRefresh);
      if (category == null) return null;

      return {
        'id': category['id'],
        'name': category['name'] ?? 'Không có tên',
        'description': category['description'] ?? 'Không có mô tả',
        'icon': _getCategoryIcon(category['name'] ?? ''),
        'clubs': category['clubs'] ?? [],
        'club_count': category['clubs']?.length?.toString() ?? '0',
      };
    } catch (e) {
      print('Lỗi khi lấy chi tiết danh mục: $e');
      throw Exception('Không thể lấy thông tin danh mục: $e');
    }
  }

  // Lấy icon tương ứng với tên danh mục
  String _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('thể thao') || name.contains('sport')) {
      return 'sports_basketball';
    } else if (name.contains('âm nhạc') || name.contains('music')) {
      return 'music_note';
    } else if (name.contains('nghệ thuật') || name.contains('art')) {
      return 'palette';
    } else if (name.contains('học thuật') || name.contains('academic')) {
      return 'school';
    } else if (name.contains('công nghệ') || name.contains('tech')) {
      return 'computer';
    } else if (name.contains('truyền thông') || name.contains('media')) {
      return 'camera_alt';
    } else if (name.contains('y tế') || name.contains('health')) {
      return 'local_hospital';
    } else if (name.contains('môi trường') || name.contains('environment')) {
      return 'eco';
    } else if (name.contains('tình nguyện') || name.contains('volunteer')) {
      return 'volunteer_activism';
    }

    // Icon mặc định
    return 'category';
  }
}

import 'package:flutter/material.dart';
import '../../../routes.dart';
import '../../../utils/image_utils.dart';
import '../../../services/CategoryService.dart';
import 'dart:developer' as developer;

Widget buildClubCard(BuildContext context, Map<String, dynamic> club,
    {VoidCallback? onTap}) {
  // Log dữ liệu club để debug
  developer.log('Club data: $club', name: 'ClubCard');

  // Xử lý URL hình ảnh sử dụng ImageUtils
  final String imageUrl =
      ImageUtils.getClubImageUrl(club) ?? 'assets/images/default.png';
  developer.log('Image URL: $imageUrl', name: 'ClubCard');

  final String title = club['name']?.toString() ?? 'No Title';
  final String description =
      club['description']?.toString() ?? 'No Description';
  final String location = club['contact_address']?.toString() ??
      club['province']?.toString() ??
      'Unknown Location';
  final String members = club['member_count']?.toString() ?? '0';

  // Lấy danh mục từ club
  String categoryName = 'Chưa phân loại';

  // Kiểm tra category từ nhiều nguồn có thể
  if (club['category'] != null) {
    if (club['category'] is Map) {
      categoryName = club['category']['name']?.toString() ?? 'Chưa phân loại';
    } else if (club['category'] is String) {
      categoryName = club['category'];
    }
  } else if (club['category_name'] != null) {
    categoryName = club['category_name'].toString();
  }

  developer.log('Category name: $categoryName', name: 'ClubCard');

  // Tạo danh sách tags từ danh mục và các tags khác
  List<String> tags = [];

  // Thêm danh mục vào tags nếu có
  if (categoryName.isNotEmpty && categoryName != 'Chưa phân loại') {
    tags.add(categoryName);
  }

  // Thêm các tags khác nếu có
  if (club['tags'] != null && club['tags'] is List) {
    tags.addAll((club['tags'] as List).map((e) => e.toString()));
  }

  // Nếu không có tags nào, thêm tag mặc định
  if (tags.isEmpty) {
    tags.add('Chung');
  }

  // Define a color scheme
  final Color primaryColor = Colors.indigo;
  final Color accentColor = Colors.amber;
  final Color backgroundColor = Colors.white;
  final Color textColor = Colors.indigo.shade900;
  final Color secondaryTextColor = Colors.indigo.shade700;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.15),
          spreadRadius: 0,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with tags
            Stack(
              children: [
                // Image with gradient overlay
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      _buildImage(imageUrl),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tags
                Positioned(
                  top: 16,
                  right: 16,
                  child: Wrap(
                    spacing: 8,
                    children:
                        tags.map((tag) => _buildTag(tag, accentColor)).toList(),
                  ),
                ),
                // Title on image
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3.0,
                          color: Color.fromARGB(100, 0, 0, 0),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  // Location and members with divider
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                            Icons.location_on_rounded, location, primaryColor),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: _buildInfoItem(Icons.people_alt_rounded,
                              '$members thành viên', primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // "Chi tiết" button
                  _buildDetailButton(context, club, primaryColor, accentColor),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildImage(String imageUrl) {
  return SizedBox(
    height: 200,
    width: double.infinity,
    child: imageUrl.startsWith('assets/')
        ? Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImage();
            },
          )
        : ImageUtils.buildNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: 200,
            placeholder: _buildErrorImage(),
          ),
  );
}

Widget _buildErrorImage() {
  return Container(
    height: 200,
    color: Colors.grey[100],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported_rounded,
            color: Colors.grey[400], size: 48),
        const SizedBox(height: 12),
        Text(
          'Could not load image',
          style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

Widget _buildTag(String tag, Color accentColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: accentColor,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Text(
      tag,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _buildInfoItem(IconData icon, String text, Color color) {
  return Row(
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget _buildDetailButton(BuildContext context, Map<String, dynamic> club,
    Color primaryColor, Color accentColor) {
  return Container(
    width: double.infinity,
    height: 54,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          primaryColor,
          primaryColor.withOpacity(0.5), // Sử dụng withOpacity thay vì alpha
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final clubId = club['id']?.toString();
          if (clubId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Club ID is missing'),
                backgroundColor: primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
            return;
          }
          Navigator.pushNamed(
            context,
            AppRoutes.clubDetail,
            arguments: clubId,
          );
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chi tiết',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

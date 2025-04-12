import 'package:flutter/material.dart';
import '../../../utils/image_utils.dart';
import 'dart:developer' as developer;

class ClubCard extends StatelessWidget {
  final Map<String, dynamic> club;
  final VoidCallback? onTap;
  final bool showBookmark;

  const ClubCard({
    Key? key,
    required this.club,
    this.onTap,
    this.showBookmark = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.teal.withOpacity(0.1),
            highlightColor: Colors.teal.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClubImage(context),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.teal.withOpacity(0.03),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildClubTitle(theme),
                      const SizedBox(height: 12),
                      _buildClubDescription(),
                      const SizedBox(height: 20),
                      Divider(
                        height: 1,
                        color: Colors.teal.withOpacity(0.2),
                        thickness: 1,
                      ),
                      const SizedBox(height: 20),
                      _buildClubInfo(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClubTitle(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            club['title'] ?? club['name'] ?? 'Không có tiêu đề',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal[800],
              height: 1.3,
              letterSpacing: 0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showBookmark)
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: const EdgeInsets.only(left: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(50),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.bookmark_border_rounded,
                    color: Colors.teal[600],
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildClubDescription() {
    return Text(
      club['description'] ?? 'Không có mô tả',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey[700],
        height: 1.5,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildClubImage(BuildContext context) {
    final theme = Theme.of(context);
    String imageUrl = _getImageUrl();

    return Container(
      height: 200,
      child: Stack(
        children: [
          // Hình ảnh chính
          Positioned.fill(
            child: Hero(
              tag: 'club_image_${club['id']}',
              child: ImageUtils.buildNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: Container(
                  height: 200,
                  color: Colors.teal[50],
                  child: Center(
                    child: Icon(Icons.image_not_supported_rounded,
                        color: Colors.teal[200], size: 48),
                  ),
                ),
              ),
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: [0.6, 1.0],
                ),
              ),
            ),
          ),

          // Category badge
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                _getCategoryName(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          // Featured badge
          if (club['is_featured'] == true)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Nổi bật',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Location on image bottom
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  _getFormattedLocation(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName() {
    if (club['category'] != null) {
      if (club['category'] is Map) {
        var category = club['category'] as Map;
        if (category.containsKey('name')) {
          return category['name'].toString();
        }
      } else if (club['category'] is String) {
        return club['category'].toString();
      }
    }
    if (club['category_id'] != null) {
      return 'Danh mục ${club['category_id']}';
    }
    return 'Câu lạc bộ';
  }

  String _getImageUrl() {
    developer.log('Getting image URL for club: ${club['id']}',
        name: 'ClubCard');

    // Sử dụng ImageUtils.getClubImageUrl để lấy URL hình ảnh
    final imageUrl = ImageUtils.getClubImageUrl(club);

    if (imageUrl != null) {
      developer.log('Using club image URL: $imageUrl', name: 'ClubCard');
      return imageUrl;
    }

    developer.log('No valid image found, using default image',
        name: 'ClubCard');
    return 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
  }

  String _getFormattedLocation() {
    String location = 'Không xác định';
    if (club['location'] != null && club['location'].toString().isNotEmpty) {
      location = club['location'].toString();
    } else if (club['contact_address'] != null &&
        club['contact_address'].toString().isNotEmpty) {
      location = club['contact_address'].toString();
    } else if (club['province'] != null &&
        club['province'].toString().isNotEmpty) {
      location = club['province'].toString();
    }

    // Limit to short form
    if (location.length > 30) {
      location = location.substring(0, 30) + '...';
    }

    return location;
  }

  Widget _buildClubInfo(ThemeData theme) {
    String memberCount = '0';
    if (club['members'] != null) {
      memberCount = club['members'].toString();
    } else if (club['members_count'] != null) {
      memberCount = club['members_count'].toString();
    } else if (club['member_count'] != null) {
      memberCount = club['member_count'].toString();
    }

    String eventCount = _getEventCount();

    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            icon: Icons.people_alt_rounded,
            label: 'Thành viên',
            value: memberCount,
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.teal[700],
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.teal[800],
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getEventCount() {
    try {
      if (club['events_count'] != null) {
        return club['events_count'].toString();
      }
      if (club['events'] != null) {
        if (club['events'] is List) {
          return (club['events'] as List).length.toString();
        } else if (club['events'] is int) {
          return club['events'].toString();
        }
      }
      return '0';
    } catch (e) {
      print('Lỗi khi lấy số sự kiện: $e');
      return '0';
    }
  }
}

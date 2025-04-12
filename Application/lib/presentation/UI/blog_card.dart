import 'package:flutter/material.dart';
import '../../utils/image_utils.dart';

class BlogCard extends StatelessWidget {
  final Map<String, dynamic> blog;
  final VoidCallback? onTap;

  const BlogCard({
    Key? key,
    required this.blog,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                _buildBlogImage(),
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
                      _buildBlogTitle(),
                      const SizedBox(height: 12),
                      _buildBlogDescription(),
                      const SizedBox(height: 20),
                      Divider(
                        height: 1,
                        color: Colors.teal.withOpacity(0.2),
                        thickness: 1,
                      ),
                      const SizedBox(height: 20),
                      _buildBlogInfo(),
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

  Widget _buildBlogImage() {
    return Container(
      height: 200,
      child: Stack(
        children: [
          // Main image
          Positioned.fill(
            child: Hero(
              tag: 'blog_image_${blog['id']}',
              child: ImageUtils.buildNetworkImage(
                imageUrl: blog['imageUrl'] ?? '',
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
                blog['category'] ?? 'Chung',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          // Author and date
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: ImageUtils.buildNetworkImage(
                      imageUrl: blog['author']?['avatar'] ?? '',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      placeholder:
                          Icon(Icons.person, color: Colors.teal[300], size: 20),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog['author']?['name'] ?? 'Ẩn danh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
                      Text(
                        blog['created_at'] ?? 'Không xác định',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogTitle() {
    return Text(
      blog['title'] ?? 'Không có tiêu đề',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.teal[800],
        height: 1.3,
        letterSpacing: 0.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBlogDescription() {
    return Text(
      blog['description'] ?? 'Không có mô tả',
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey[700],
        height: 1.5,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildBlogInfo() {
    return Row(
      children: [
        _buildInfoItem(
          icon: Icons.remove_red_eye_rounded,
          value: blog['views_count']?.toString() ?? '0',
          label: 'Lượt xem',
        ),
        SizedBox(width: 16),
        _buildInfoItem(
          icon: Icons.favorite_rounded,
          value: blog['likes_count']?.toString() ?? '0',
          label: 'Lượt thích',
        ),
        SizedBox(width: 16),
        _buildInfoItem(
          icon: Icons.comment_rounded,
          value: blog['comments_count']?.toString() ?? '0',
          label: 'Bình luận',
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.teal[700],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

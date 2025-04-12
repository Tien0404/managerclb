import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/BlogService.dart';
import '../../../utils/image_utils.dart';

class BlogCard extends StatefulWidget {
  final Map<String, dynamic> blog;

  const BlogCard({Key? key, required this.blog}) : super(key: key);

  @override
  _BlogCardState createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  String _authorName = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthorData();
  }

  Future<void> _loadAuthorData() async {
    try {
      final clubId = widget.blog['club_id'];

      if (clubId != null) {
        final clubName = await BlogApi.getClubName(clubId);
        if (mounted) {
          setState(() {
            _authorName = clubName;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Lỗi khi tải thông tin tác giả: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/blog/:id',
          arguments: widget.blog['id'].toString(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeaturedImage(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateAndTitle(),
                  const SizedBox(height: 16),
                  _buildAuthorInfo(),
                  const SizedBox(height: 16),
                  _buildContent(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedImage() {
    return Stack(
      children: [
        // Image
        SizedBox(
          width: double.infinity,
          height: 220,
          child: ImageUtils.buildNetworkImage(
            imageUrl: widget.blog['image'] ??
                widget.blog['background_images']?[0]?['url'] ??
                widget.blog['background_images']?[0]?['image_url'],
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            placeholder: _buildFallbackImage(),
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
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),

        // Category badge
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              "Blog",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          Icons.article_rounded,
          size: 64,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildDateAndTitle() {
    // Parse the date
    DateTime? date;
    try {
      date = DateTime.parse(widget.blog['created_at'].toString());
    } catch (e) {
      print('Error parsing date: $e');
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date section
        if (date != null)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).primaryColor,
                    height: 1.0,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(date).toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 16),
        // Title section
        Expanded(
          child: Text(
            widget.blog['title'] ?? "Không có tiêu đề",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoading ? "Đang tải..." : _authorName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  "Người đăng",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Text(
      widget.blog['content'] ?? "Không có nội dung",
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey[700],
        height: 1.5,
        letterSpacing: 0.3,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.visibility_outlined, '120', 'Lượt xem'),
          _buildActionButton(Icons.favorite_border, '36', 'Yêu thích'),
          _buildActionButton(Icons.chat_bubble_outline, '8', 'Bình luận'),
          _buildActionButton(Icons.share_outlined, '', 'Chia sẻ'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count, String label) {
    return Tooltip(
      message: label,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          if (count.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

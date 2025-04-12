import 'package:flutter/material.dart';
import '../../utils/image_utils.dart';

class HistoryEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback? onTap;

  const HistoryEventCard({
    Key? key,
    required this.event,
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
                _buildEventImage(),
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
                      _buildEventTitle(),
                      const SizedBox(height: 12),
                      _buildEventDescription(),
                      const SizedBox(height: 20),
                      Divider(
                        height: 1,
                        color: Colors.teal.withOpacity(0.2),
                        thickness: 1,
                      ),
                      const SizedBox(height: 20),
                      _buildEventInfo(),
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

  Widget _buildEventImage() {
    return Container(
      height: 200,
      child: Stack(
        children: [
          // Main image
          Positioned.fill(
            child: Hero(
              tag: 'event_image_${event['id']}',
              child: ImageUtils.buildNetworkImage(
                imageUrl: event['imageUrl'] ?? '',
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

          // Event type badge
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
                event['type'] ?? 'Sự kiện',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          // Date and location
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  event['date'] ?? 'Không xác định',
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
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event['location'] ?? 'Không xác định',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTitle() {
    return Text(
      event['title'] ?? 'Không có tiêu đề',
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

  Widget _buildEventDescription() {
    return Text(
      event['description'] ?? 'Không có mô tả',
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

  Widget _buildEventInfo() {
    return Row(
      children: [
        _buildInfoItem(
          icon: Icons.people_alt_rounded,
          value: event['participants_count']?.toString() ?? '0',
          label: 'Người tham gia',
        ),
        SizedBox(width: 16),
        _buildInfoItem(
          icon: Icons.favorite_rounded,
          value: event['likes_count']?.toString() ?? '0',
          label: 'Lượt thích',
        ),
        SizedBox(width: 16),
        _buildInfoItem(
          icon: Icons.comment_rounded,
          value: event['comments_count']?.toString() ?? '0',
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

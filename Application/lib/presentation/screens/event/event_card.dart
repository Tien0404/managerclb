import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/image_utils.dart';

// Since we don't have the models.dart file yet, define Event class directly here
class Event {
  final int id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final Category category;
  final Club club;
  final List<BackgroundImage> backgroundImages;
  final int attendees;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.category,
    required this.club,
    required this.backgroundImages,
    required this.attendees,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      DateTime parseDate(String? dateStr) {
        if (dateStr == null) return DateTime.now();
        try {
          return DateTime.parse(dateStr); // Thử parse ISO 8601
        } catch (e) {
          return DateFormat('yyyy-MM-dd HH:mm:ss')
              .parse(dateStr); // Laravel format
        }
      }

      return Event(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Không có tên',
        description: json['content'] ?? 'Không có mô tả',
        startDate: parseDate(json['start_date']),
        endDate: parseDate(json['end_date']),
        location: json['location'] ?? 'Không có địa điểm',
        category: Category(
          id: json['category_id'] ??
              (json['category'] != null ? json['category']['id'] ?? 0 : 0),
          name: json['category'] != null
              ? json['category']['name'] ?? 'Không có danh mục'
              : 'Không có danh mục',
          subtext: json['category'] != null
              ? json['category']['description'] ?? ''
              : '',
          icon: Icons.event,
        ),
        club: Club(
          name: json['club'] != null
              ? json['club']['name'] ?? 'Không có CLB'
              : 'Không có CLB',
          logoUrl: json['club'] != null
              ? json['club']['logo_url'] ?? 'https://via.placeholder.com/50'
              : 'https://via.placeholder.com/50',
        ),
        backgroundImages: json['background_images'] != null
            ? (json['background_images'] as List)
                .map((image) =>
                    BackgroundImage(imageUrl: image['image_url'] ?? ''))
                .toList()
            : [],
        attendees: json['registered_participants'] ?? 0,
      );
    } catch (e) {
      print('Error parsing JSON: $e, JSON: $json');
      return Event(
        id: 0,
        name: 'Lỗi dữ liệu',
        description: 'Không thể phân tích',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        location: 'N/A',
        category: Category(id: 0, name: 'N/A', subtext: '', icon: Icons.error),
        club: Club(name: 'N/A', logoUrl: 'https://via.placeholder.com/50'),
        backgroundImages: [],
        attendees: 0,
      );
    }
  }
}

class Category {
  final int? id;
  final String name;
  final String subtext;
  final IconData icon;

  Category(
      {required this.id,
      required this.name,
      required this.subtext,
      this.icon = Icons.event});
}

class Club {
  final String name;
  final String logoUrl;

  Club({required this.name, required this.logoUrl});
}

class BackgroundImage {
  final String imageUrl;

  BackgroundImage({required this.imageUrl});
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({Key? key, required this.event, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventImage(context),
            _buildEventContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage(BuildContext context) {
    return Stack(
      children: [
        // Event Image
        Container(
          height: 150,
          width: double.infinity,
          child: event.backgroundImages.isNotEmpty
              ? ImageUtils.buildNetworkImage(
                  imageUrl: event.backgroundImages[0].imageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: _buildImagePlaceholder(),
                )
              : _buildImagePlaceholder(),
        ),

        // Gradient overlay
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              stops: [0.5, 1.0],
            ),
          ),
        ),

        // Date badge
        Positioned(
          top: 12,
          left: 12,
          child: _buildDateBadge(),
        ),

        // Category chip
        Positioned(
          top: 12,
          right: 12,
          child: _buildCategoryChip(),
        ),

        // Time and location
        Positioned(
          bottom: 12,
          left: 12,
          right: 12,
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text(
                DateFormat('HH:mm').format(event.startDate),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.location_on_rounded, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.location,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.teal[100],
      child: Center(
        child: Icon(
          Icons.event,
          size: 50,
          color: Colors.teal[300],
        ),
      ),
    );
  }

  Widget _buildDateBadge() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('dd').format(event.startDate),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal[600],
            ),
          ),
          Text(
            DateFormat('MMM').format(event.startDate).toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.teal[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.teal[400],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        event.category.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEventContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event title
          Text(
            event.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal[800],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),

          // Event description
          if (event.description.isNotEmpty) ...[
            Text(
              event.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16),
          ],

          // Organizer info
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.teal[50],
                backgroundImage: NetworkImage(event.club.logoUrl),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.club.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Tổ chức",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.teal[600]),
                    SizedBox(width: 4),
                    Text(
                      "${event.attendees} người tham gia",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.teal[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

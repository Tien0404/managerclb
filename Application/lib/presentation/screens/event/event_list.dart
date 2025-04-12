import 'package:flutter/material.dart';
import 'event_card.dart';

class EventList extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final List<Event> filteredEvents;
  final VoidCallback onRefresh;
  final Function(int) onEventTap;

  const EventList({
    required this.isLoading,
    required this.hasError,
    required this.filteredEvents,
    required this.onRefresh,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lime[600]!)),
        ),
      );
    } else if (hasError) {
      return SliverFillRemaining(child: _buildErrorState(context));
    } else if (filteredEvents.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => EventCard(
            event: filteredEvents[index],
            onTap: () => onEventTap(filteredEvents[index].id),
          ),
          childCount: filteredEvents.length,
        ),
      );
    }
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            "Đã xảy ra lỗi",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[400]),
          ),
          SizedBox(height: 8),
          Text("Không thể tải danh sách sự kiện",
              style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh),
            label: Text("Thử lại"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lime[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            "Không tìm thấy sự kiện",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          Text("Hãy thử tìm kiếm với từ khóa khác",
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

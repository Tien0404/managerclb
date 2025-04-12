import 'package:flutter/material.dart';
import '../../../models/event_model.dart';
import '../../../services/JoinRequestService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/user_model.dart';
import 'package:intl/intl.dart';
import '../../../routes.dart';
import '../../../utils/image_utils.dart';

class JoinedEventsScreen extends StatefulWidget {
  const JoinedEventsScreen({Key? key}) : super(key: key);

  @override
  State<JoinedEventsScreen> createState() => _JoinedEventsScreenState();
}

class _JoinedEventsScreenState extends State<JoinedEventsScreen> {
  final JoinRequestService _joinRequestService = JoinRequestService();
  bool _isLoading = true;
  List<Event> _events = [];
  User? _currentUser;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      print('DEBUG: User data from SharedPreferences: $userString');

      if (userString != null && userString.isNotEmpty) {
        try {
          final userData = json.decode(userString);
          _currentUser = User.fromJson(userData);
          print('DEBUG: User ID loaded: ${_currentUser?.id}');
          await _loadJoinedEvents();
        } catch (e) {
          print('DEBUG: Error parsing user data: $e');
          setState(() {
            _error = 'Định dạng dữ liệu người dùng không hợp lệ';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Vui lòng đăng nhập để xem sự kiện của bạn';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error loading user: $e');
      setState(() {
        _error = 'Không thể tải thông tin người dùng: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadJoinedEvents() async {
    if (_currentUser == null) {
      print('DEBUG: Cannot load events - user is null');
      return;
    }

    try {
      print('DEBUG: Loading events for user ID: ${_currentUser!.id}');
      final events = await _joinRequestService.getUserEvents(_currentUser!.id);
      print('DEBUG: Loaded ${events.length} events');
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error loading events: $e');
      setState(() {
        _error = 'Không thể tải danh sách sự kiện: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Chưa xác định';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _getEventStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'completed':
        return 'Đã kết thúc';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Color _getEventStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sự kiện của tôi'),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child:
                      Text(_error, style: const TextStyle(color: Colors.red)))
              : _events.isEmpty
                  ? const Center(child: Text('Bạn chưa tham gia sự kiện nào'))
                  : RefreshIndicator(
                      onRefresh: _loadJoinedEvents,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                // Điều hướng đến trang chi tiết sự kiện sử dụng routes
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.eventDetail,
                                  arguments: event.id.toString(),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header hình ảnh
                                  Container(
                                    height: 150,
                                    child: ImageUtils.buildNetworkImage(
                                      imageUrl: event.backgroundImages !=
                                                  null &&
                                              event.backgroundImages!.isNotEmpty
                                          ? event.backgroundImages![0]['url'] ??
                                              event.backgroundImages![0]
                                                  ['image_url']
                                          : null,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      placeholder: Container(
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.event,
                                            size: 50, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Tên sự kiện và trạng thái
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                event.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getEventStatusColor(
                                                    event.status),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _getEventStatusText(
                                                    event.status),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Tên câu lạc bộ tổ chức
                                        if (event.club != null)
                                          Row(
                                            children: [
                                              const Icon(Icons.group,
                                                  size: 16,
                                                  color: Colors.indigo),
                                              const SizedBox(width: 8),
                                              Text(
                                                event.club!.name,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 12),
                                        // Thời gian sự kiện
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time,
                                                size: 16, color: Colors.indigo),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Bắt đầu: ${_formatDateTime(event.startDate)}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time_filled,
                                                size: 16, color: Colors.indigo),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Kết thúc: ${_formatDateTime(event.endDate)}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Địa điểm sự kiện
                                        if (event.location != null &&
                                            event.location!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 16,
                                                  color: Colors.indigo),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  event.location!,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        // Mô tả ngắn
                                        if (event.shortDescription != null &&
                                            event.shortDescription!
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            event.shortDescription!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../services/EventService.dart';
import '../../../services/JoinRequestService.dart';
import '../../../utils/date_formatter.dart';
import '../../../utils/image_utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../UI/footer.dart';
import '../../../routes.dart';
import 'dart:developer' as developer;

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _eventData = {};
  String _errorMessage = '';

  // Trạng thái đăng ký tham gia
  bool isJoining = false;
  String? joinStatus;
  final JoinRequestService joinRequestService = JoinRequestService();

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
    _checkJoinStatus();
  }

  Future<void> _loadEventDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final eventData = await EventApiService.getEventById(
          int.parse(widget.eventId),
          forceRefresh: true);

      // Log event data for debugging
      developer.log('======== EVENT DETAILS ========');
      developer.log('Event ID: ${eventData['id']}');
      developer.log('Event Name: ${eventData['name']}');
      developer.log(
          'Event Category: ${eventData['category_id']} - ${eventData['category']?['name']}');
      developer.log(
          'Event Club: ${eventData['club_id']} - ${eventData['club']?['name']}');
      developer.log(
          'Event Dates: ${eventData['start_date']} to ${eventData['end_date']}');
      developer
          .log('Event Location: ${eventData['location'] ?? 'Not specified'}');
      developer.log(
          'Max Participants: ${eventData['max_participants'] ?? 'Unlimited'}');
      developer
          .log('Current Participants: ${eventData['registered_participants']}');
      developer.log('Event Status: ${eventData['status']}');
      developer.log('Event Content: ${eventData['content']}');

      // Log club details
      if (eventData['club'] != null) {
        developer.log('---- Club Details ----');
        developer.log('Club Name: ${eventData['club']['name']}');
        developer.log('Club Description: ${eventData['club']['description']}');
        developer.log(
            'Club Contact: ${eventData['club']['contact_email']} | ${eventData['club']['contact_phone']}');
        developer.log(
            'Club Location: ${eventData['club']['province']} - ${eventData['club']['contact_address']}');
      }

      // Log category details
      if (eventData['category'] != null) {
        developer.log('---- Category Details ----');
        developer.log('Category Name: ${eventData['category']['name']}');
        developer.log(
            'Category Description: ${eventData['category']['description']}');
        developer.log('Category Type: ${eventData['category']['type']}');
      }

      // Log complete JSON for reference
      developer.log('---- Complete Event JSON ----');
      developer.log(json.encode(eventData));
      developer.log('==============================');

      setState(() {
        _eventData = eventData;
        _isLoading = false;
      });

      developer.log('Event data loaded: ${_eventData['name']}');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Không thể tải thông tin sự kiện. Vui lòng thử lại sau.\nLỗi: $e';
      });
      developer.log('Error loading event details: $e', error: e);
    }
  }

  // Kiểm tra trạng thái tham gia sự kiện
  Future<void> _checkJoinStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userString = prefs.getString('user');

      developer.log('==== CHECK JOIN STATUS ====');
      developer.log('Token from SharedPreferences: $token');
      developer.log('User String from SharedPreferences: $userString');

      if (token == null || userString == null) {
        developer.log('User not logged in - Missing token or user');
        return;
      }

      // Giải mã chuỗi JSON thành Map
      final userData = json.decode(userString);
      final userId = userData['id'];

      developer.log('Extracted User ID: $userId');

      if (userId == null) {
        developer.log('User ID is null after extraction');
        return;
      }

      final status = await joinRequestService.checkEventStatus(
        userId,
        int.parse(widget.eventId),
      );

      developer.log('Join status response: $status');

      setState(() {
        joinStatus = status['status'];
      });
    } catch (e) {
      developer.log('Error checking join status: $e');
    }
  }

  // Xử lý đăng ký tham gia sự kiện
  Future<void> _handleJoinEvent() async {
    try {
      setState(() {
        isJoining = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userString = prefs.getString('user');

      developer.log('==== HANDLE JOIN EVENT ====');
      developer.log('Token from SharedPreferences: $token');
      developer.log('User String from SharedPreferences: $userString');
      developer.log('Event ID: ${widget.eventId}');

      if (token == null || userString == null) {
        developer.log('User not logged in - Missing token or user');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để tham gia sự kiện'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Giải mã chuỗi JSON thành Map
      final userData = json.decode(userString);
      final userId = userData['id'];

      developer.log('Extracted User ID: $userId');

      if (userId == null) {
        developer.log('User ID is null after extraction');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xác định thông tin người dùng'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final result = await joinRequestService.createJoinRequest(
        userId: userId,
        type: 'event',
        eventId: int.parse(widget.eventId),
        message: 'Tôi muốn tham gia sự kiện ${_eventData['name']}',
        status: 'request',
      );

      developer.log('Join request response: $result');

      // Kiểm tra status code 409 - Conflict (đã có yêu cầu tham gia)
      if (result['status_code'] == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                result['message'] ?? 'Bạn đã có yêu cầu tham gia sự kiện này'),
            backgroundColor: Colors.orange,
          ),
        );
        // Vẫn cập nhật trạng thái UI để hiển thị "Đang chờ duyệt"
        _checkJoinStatus();
        return;
      }

      // Kiểm tra response thành công dựa trên cả success flag và message
      if (result['success'] == true ||
          result['message']?.toString().contains('thành công') == true) {
        developer.log('Join request successful');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi yêu cầu tham gia sự kiện thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _checkJoinStatus(); // Cập nhật lại trạng thái
      } else {
        // Chỉ throw exception khi thực sự có lỗi
        throw Exception(result['message'] ?? 'Có lỗi xảy ra');
      }
    } catch (e) {
      developer.log('Error joining event: $e');
      // Kiểm tra nếu lỗi chứa từ khóa "thành công" thì không hiển thị như lỗi
      if (!e.toString().contains('thành công')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isJoining = false;
      });
    }
  }

  // Widget nút đăng ký tham gia sự kiện
  Widget _buildJoinButton(ThemeData theme) {
    final Color primaryColor = Colors.teal; // Thay đổi từ đỏ san hô sang teal

    // Nếu đã tham gia và được chấp nhận
    if (joinStatus == 'approved') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: Icon(Icons.check_circle),
          label: Text('Đã tham gia'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.green,
            disabledForegroundColor: Colors.white,
          ),
        ),
      );
    }

    // Nếu đang chờ duyệt (xử lý cả 'request' và 'pending')
    if (joinStatus == 'pending' || joinStatus == 'request') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: Icon(Icons.hourglass_empty),
          label: Text('Đang chờ duyệt'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.orange,
            disabledForegroundColor: Colors.white,
          ),
        ),
      );
    }

    // Kiểm tra nếu sự kiện đã đủ người tham gia
    final int maxParticipants =
        int.tryParse(_eventData['max_participants']?.toString() ?? '0') ?? 0;
    final int registeredParticipants = int.tryParse(
            _eventData['registered_participants']?.toString() ?? '0') ??
        0;

    final bool isFull =
        maxParticipants > 0 && registeredParticipants >= maxParticipants;

    // Nút đăng ký tham gia hoặc thông báo đã đủ số lượng
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isFull || isJoining ? null : _handleJoinEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[400],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isJoining
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isFull ? 'Đã đủ số lượng tham gia' : 'Đăng ký tham gia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Colors.teal; // Thay đổi từ đỏ san hô sang teal

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _eventData['name'] ?? 'Chi tiết sự kiện',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chức năng chia sẻ đang phát triển')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingView(primaryColor)
          : _errorMessage.isNotEmpty
              ? _buildErrorView(primaryColor)
              : _buildEventDetailView(primaryColor),
    );
  }

  Widget _buildLoadingView(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải thông tin sự kiện...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEventDetails,
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Quay lại'),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetailView(Color primaryColor) {
    // Extract event data
    final String eventName = _eventData['name'] ?? 'Sự kiện không có tên';
    final String eventStatus = _eventData['status'] ?? 'unknown';
    final String clubName =
        _eventData['club']?['name'] ?? 'Câu lạc bộ không xác định';
    final String clubDescription =
        _eventData['club']?['description'] ?? 'Không có mô tả về câu lạc bộ';
    final String clubContact = _eventData['club']?['contact_email'] != null
        ? '${_eventData['club']?['contact_email']} | ${_eventData['club']?['contact_phone'] ?? ""}'
        : 'Không có thông tin liên hệ';
    final String categoryName =
        _eventData['category']?['name'] ?? 'Không có danh mục';
    final String location = _eventData['location'] ??
        (_eventData['club']?['contact_address'] ?? 'Chưa có địa điểm');
    final String province = _eventData['club']?['province'] ?? '';
    final String fullLocation = province.isNotEmpty && location != province
        ? '$location, $province'
        : location;
    final String content = _eventData['content'] ?? 'Không có mô tả chi tiết';

    // Parse dates
    DateTime? startDate, endDate;
    try {
      startDate = _eventData['start_date'] != null
          ? DateTime.parse(_eventData['start_date'])
          : null;
      endDate = _eventData['end_date'] != null
          ? DateTime.parse(_eventData['end_date'])
          : null;
    } catch (e) {
      developer.log('Error parsing dates: $e');
    }

    // Format dates
    final String formattedStartDate = startDate != null
        ? DateFormatter.formatDateTime(startDate)
        : 'Chưa có ngày bắt đầu';
    final String formattedEndDate = endDate != null
        ? DateFormatter.formatDateTime(endDate)
        : 'Chưa có ngày kết thúc';

    // Participants
    final int maxParticipants =
        int.tryParse(_eventData['max_participants']?.toString() ?? '0') ?? 0;
    final int registeredParticipants = int.tryParse(
            _eventData['registered_participants']?.toString() ?? '0') ??
        0;

    // Background images
    final List<dynamic> backgroundImages =
        _eventData['background_images'] ?? [];
    final String? firstImageUrl = backgroundImages.isNotEmpty
        ? backgroundImages.first['image_url']
        : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Indicator
          Container(
            color: _getStatusColor(eventStatus),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Center(
              child: Text(
                _getStatusText(eventStatus),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // Event image or banner
          Stack(
            children: [
              ImageUtils.buildCoverImage(
                imageUrl: firstImageUrl,
                width: double.infinity,
                aspectRatio: 16 / 9,
                placeholder: Container(
                  height: 220,
                  width: double.infinity,
                  color: Color(0xFFE0F2F1), // Màu teal rất nhạt
                  child: Center(
                    child: Icon(
                      Icons.event,
                      size: 80,
                      color: Color(0xFFB2DFDB), // Màu teal nhạt
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
                        Colors.black.withOpacity(0.7),
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
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Date overlay
              if (startDate != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        formattedStartDate,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Event title and organizer
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 16),

                // Organizer info
                _buildOrganizerCard(clubName, clubDescription, primaryColor),

                SizedBox(height: 24),

                // Divider with text
                _buildDividerWithText('Thông tin chi tiết'),

                SizedBox(height: 16),

                // Event details in a card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Time section
                        _buildInfoItem(
                          icon: Icons.access_time,
                          title: 'Thời gian',
                          details: [
                            _buildDetailRow(
                              icon: Icons.play_arrow,
                              text: formattedStartDate,
                              label: 'Bắt đầu',
                            ),
                            _buildDetailRow(
                              icon: Icons.stop,
                              text: formattedEndDate,
                              label: 'Kết thúc',
                            ),
                          ],
                        ),

                        Divider(height: 32),

                        // Location section
                        _buildInfoItem(
                          icon: Icons.location_on,
                          title: 'Địa điểm',
                          details: [
                            _buildDetailRow(
                              text: fullLocation,
                            ),
                          ],
                        ),

                        if (maxParticipants > 0) ...[
                          Divider(height: 32),

                          // Participants section
                          _buildInfoItem(
                            icon: Icons.people,
                            title: 'Số lượng người tham gia',
                            details: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        registeredParticipants.toString(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      Text(
                                        ' / $maxParticipants',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: maxParticipants > 0
                                          ? registeredParticipants /
                                              maxParticipants
                                          : 0.0,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        registeredParticipants >=
                                                maxParticipants
                                            ? Colors.red
                                            : primaryColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    registeredParticipants >= maxParticipants
                                        ? 'Đã đủ số lượng người tham gia'
                                        : '${maxParticipants - registeredParticipants} chỗ trống còn lại',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],

                        Divider(height: 32),

                        // Contact info
                        _buildInfoItem(
                          icon: Icons.contact_phone,
                          title: 'Liên hệ',
                          details: [
                            _buildDetailRow(
                              text: clubContact,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Content section
                _buildDividerWithText('Nội dung chi tiết'),

                SizedBox(height: 16),

                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Photo Gallery Section
                if (backgroundImages.isNotEmpty) ...[
                  SizedBox(height: 24),
                  _buildDividerWithText('Hình ảnh sự kiện'),
                  SizedBox(height: 16),
                  _buildGallerySection(),
                ],
              ],
            ),
          ),

          // Register button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildJoinButton(ThemeData()),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizerCard(
      String name, String description, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0F2F1), // Màu teal rất nhẹ
            Color(0xFFB2DFDB), // Màu teal nhạt
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFB2DFDB),
            child: Icon(
              Icons.groups,
              color: primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00695C), // Màu teal đậm
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Đơn vị tổ chức',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00695C).withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF00897B), // Màu teal trung bình
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: Colors.teal,
          size: 20,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00695C), // Màu teal đậm
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: Color(0xFFB2DFDB), // Màu teal nhạt
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required List<Widget> details,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFB2DFDB), // Màu teal nhạt
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Color(0xFF00695C), // Màu teal đậm
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00695C), // Màu teal đậm
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    IconData? icon,
    required String text,
    String? label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey[500]),
            SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Photo Gallery Section
  Widget _buildGallerySection() {
    final List<dynamic> images = _eventData['background_images'] ?? [];

    if (images.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.grey[400],
              ),
              SizedBox(height: 8),
              Text(
                'Không có hình ảnh',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ImageUtils.buildHorizontalGallery(
      images: images,
      height: 180,
      spacing: 12.0,
      borderRadius: BorderRadius.circular(12),
      imageUrlExtractor: (image) => image['url'] ?? image['image_url'],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'ended':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'SỰ KIỆN ĐANG DIỄN RA';
      case 'pending':
        return 'SỰ KIỆN SẮP DIỄN RA';
      case 'cancelled':
        return 'SỰ KIỆN ĐÃ HỦY';
      case 'ended':
        return 'SỰ KIỆN ĐÃ KẾT THÚC';
      default:
        return status.toUpperCase();
    }
  }
}

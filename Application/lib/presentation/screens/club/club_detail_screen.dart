import 'package:flutter/material.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/ClubService.dart';
import '../../../services/EventService.dart';
import '../../../services/JoinRequestService.dart';
import '../../../utils/image_utils.dart';
import 'dart:convert';
import '../event/event_detail_screen.dart'; // Import event detail screen

class ClubDetailScreen extends StatefulWidget {
  final String clubId;

  const ClubDetailScreen({Key? key, required this.clubId}) : super(key: key);

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  Map<String, dynamic>? clubDetails;
  bool isLoading = true;
  String? error;
  bool isJoining = false;
  String? joinStatus;
  JoinRequestService joinRequestService = JoinRequestService();

  @override
  void initState() {
    super.initState();
    _loadClubDetails();
    _checkJoinStatus();
  }

  Future<void> _loadClubDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Kiểm tra kết nối internet
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('Không có kết nối internet. Vui lòng thử lại sau.');
      }

      // Kiểm tra ID hợp lệ
      if (widget.clubId.isEmpty) {
        throw Exception('ID câu lạc bộ không hợp lệ');
      }

      // Gọi API để lấy thông tin chi tiết câu lạc bộ - FORCE REFRESH để luôn lấy dữ liệu mới
      final clubData =
          await ClubService().getClub(widget.clubId, forceRefresh: true);

      if (clubData == null) {
        throw Exception('Không tìm thấy thông tin câu lạc bộ');
      }

      // Log chi tiết dữ liệu câu lạc bộ
      print('==== CHI TIẾT CÂU LẠC BỘ ====');
      print('ID: ${clubData['id']}');
      print('Tên: ${clubData['name']}');
      print('Mô tả: ${clubData['description']}');
      print('Số thành viên: ${clubData['member_count']}');
      print('Email: ${clubData['contact_email']}');
      print('Điện thoại: ${clubData['contact_phone']}');
      print('Địa chỉ: ${clubData['contact_address']}');
      print('Trạng thái: ${clubData['status']}');

      // Log thông tin người tạo
      if (clubData['user'] != null) {
        print('==== NGƯỜI TẠO ====');
        print('ID: ${clubData['user']['id']}');
        print('Tên: ${clubData['user']['username']}');
        print('Email: ${clubData['user']['email']}');
      }

      // Log danh mục
      if (clubData['category'] != null) {
        print('==== DANH MỤC ====');
        print('ID: ${clubData['category']['id']}');
        print('Tên: ${clubData['category']['name']}');
        print('Mô tả: ${clubData['category']['description']}');
      }

      // Log hình ảnh
      if (clubData['background_images'] != null) {
        print('==== HÌNH ẢNH ====');
        print('Số lượng: ${(clubData['background_images'] as List).length}');
        for (var image in clubData['background_images']) {
          print('ID: ${image['id']}');
          print('URL: ${image['image_url']}');
          print('Là logo: ${image['is_logo']}');
        }
      }

      // Log sự kiện
      if (clubData['events'] != null) {
        print('==== SỰ KIỆN ====');
        print('Số lượng: ${(clubData['events'] as List).length}');
        for (var event in clubData['events']) {
          print('ID: ${event['id']}');
          print('Tên: ${event['name']}');
          print('Ngày bắt đầu: ${event['start_date']}');
          print('Ngày kết thúc: ${event['end_date']}');
          print('Địa điểm: ${event['location']}');
          print('Trạng thái: ${event['status']}');
        }
      }

      setState(() {
        clubDetails = clubData;
        isLoading = false;
      });
    } on SocketException {
      setState(() {
        error =
            'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi tải thông tin CLB: $e");
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Kiểm tra trạng thái tham gia CLB
  Future<void> _checkJoinStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userString = prefs.getString('user');

      print('==== CHECK JOIN STATUS ====');
      print('Token from SharedPreferences: $token');
      print('User String from SharedPreferences: $userString');

      if (token == null || userString == null) {
        print('User not logged in - Missing token or user');
        return;
      }

      // Giải mã chuỗi JSON thành Map
      final userData = json.decode(userString);
      final userId = userData['id'];

      print('Extracted User ID: $userId');

      if (userId == null) {
        print('User ID is null after extraction');
        return;
      }

      final status = await joinRequestService.checkClubStatus(
        userId,
        int.parse(widget.clubId),
      );

      print('Join status response: $status');

      setState(() {
        joinStatus = status['status'];
      });
    } catch (e) {
      print('Error checking join status: $e');
    }
  }

  // Xử lý đăng ký tham gia CLB
  Future<void> _handleJoinClub() async {
    try {
      setState(() {
        isJoining = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userString = prefs.getString('user');

      print('==== HANDLE JOIN CLUB ====');
      print('Token from SharedPreferences: $token');
      print('User String from SharedPreferences: $userString');
      print('Club ID: ${widget.clubId}');

      if (token == null || userString == null) {
        print('User not logged in - Missing token or user');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để tham gia CLB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Giải mã chuỗi JSON thành Map
      final userData = json.decode(userString);
      final userId = userData['id'];

      print('Extracted User ID: $userId');

      if (userId == null) {
        print('User ID is null after extraction');
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
        type: 'club',
        clubId: int.parse(widget.clubId),
        message: 'Tôi muốn tham gia CLB ${clubDetails?['name']}',
        status: 'request', // Thêm status rõ ràng
      );

      print('Join request response: $result');

      // Kiểm tra status code 409 - Conflict (đã có yêu cầu tham gia)
      if (result['status_code'] == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result['message'] ?? 'Bạn đã có yêu cầu tham gia CLB này'),
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
        print('Join request successful'); // Thêm log để debug
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi yêu cầu tham gia CLB thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _checkJoinStatus(); // Cập nhật lại trạng thái
      } else {
        // Chỉ throw exception khi thực sự có lỗi
        throw Exception(result['message'] ?? 'Có lỗi xảy ra');
      }
    } catch (e) {
      print('Error joining club: $e');
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
          appBar: AppBar(title: const Text('Chi tiết Câu Lạc Bộ')),
          body: const Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết Câu Lạc Bộ')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadClubDetails,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (clubDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết Câu Lạc Bộ')),
        body: const Center(
          child: Text('Không có thông tin câu lạc bộ'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(clubDetails!['name'] ?? 'Chi tiết Câu Lạc Bộ'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildClubHeader(),
            _buildImageGallery(),
            _buildAboutSection(),
            _buildContactInfo(),
            _buildMembersList(),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildClubHeader() {
    return Stack(
      children: [
        // Cover image
        ImageUtils.buildCoverImage(
          imageUrl: _getClubCoverImage(),
          width: double.infinity,
          aspectRatio: 16 / 9,
          placeholder: Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[300],
            child: Center(
              child: Icon(
                Icons.image,
                size: 64,
                color: Colors.grey[500],
              ),
            ),
          ),
        ),

        // Gradient overlay
        Container(
          height: 200,
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

        // Club logo
        Positioned(
          bottom: 20,
          left: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildClubLogo(),
              SizedBox(width: 16),
              // Club name and details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    clubDetails?['name'] ?? 'Tên CLB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  if (clubDetails?['category'] != null)
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[700]!.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        clubDetails?['category']['name'] ?? 'Danh mục',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Thêm nút đăng ký tham gia CLB
        Positioned(
          top: 16,
          right: 16,
          child: _buildJoinButton(),
        ),
      ],
    );
  }

  Widget _buildClubLogo() {
    final String? logoUrl = _getClubLogoUrl();

    return ImageUtils.buildCircleAvatar(
      imageUrl: logoUrl,
      radius: 40,
      backgroundColor: Colors.white,
      placeholder: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.2),
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            clubDetails?['name']?.substring(0, 1).toUpperCase() ?? 'C',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
      ),
    );
  }

  // Function to get club logo URL
  String? _getClubLogoUrl() {
    if (clubDetails == null) return null;

    // First check if logo field exists
    if (clubDetails!['logo'] != null) {
      return clubDetails!['logo'];
    }

    // Then check background_images for a logo image
    if (clubDetails!['background_images'] != null &&
        clubDetails!['background_images'] is List &&
        (clubDetails!['background_images'] as List).isNotEmpty) {
      // Try to find logo image
      for (var img in clubDetails!['background_images']) {
        if (img['is_logo'] == true) {
          return img['url'] ?? img['image_url'];
        }
      }

      // If no logo found, return first image
      var firstImage = (clubDetails!['background_images'] as List).first;
      return firstImage['url'] ?? firstImage['image_url'];
    }

    return null;
  }

  // Function to get club cover image
  String? _getClubCoverImage() {
    if (clubDetails == null) return null;

    // Check if background_images exist and contain cover images
    if (clubDetails!['background_images'] != null &&
        clubDetails!['background_images'] is List &&
        (clubDetails!['background_images'] as List).isNotEmpty) {
      // First try to find a non-logo image
      for (var img in clubDetails!['background_images']) {
        if (img['is_logo'] != true) {
          return img['url'] ?? img['image_url'];
        }
      }

      // If all are logos, just return the first image
      var firstImage = (clubDetails!['background_images'] as List).first;
      return firstImage['url'] ?? firstImage['image_url'];
    }

    return null;
  }

  Widget _buildImageGallery() {
    // Check if we have images
    if (clubDetails == null ||
        clubDetails!['background_images'] == null ||
        (clubDetails!['background_images'] as List).isEmpty) {
      return SizedBox.shrink();
    }

    final List<dynamic> images = clubDetails!['background_images'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hình ảnh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          SizedBox(height: 12),
          ImageUtils.buildHorizontalGallery(
            images: images,
            height: 160,
            spacing: 12.0,
            borderRadius: BorderRadius.circular(12),
            imageUrlExtractor: (image) => image['url'] ?? image['image_url'],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chúng tôi là ai',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getDescription(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin liên hệ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (clubDetails!['contact_email'] != null &&
              clubDetails!['contact_email'].toString().isNotEmpty)
            _buildContactItem(Icons.email, clubDetails!['contact_email']),
          if (clubDetails!['contact_phone'] != null &&
              clubDetails!['contact_phone'].toString().isNotEmpty)
            _buildContactItem(Icons.phone, clubDetails!['contact_phone']),
          if (clubDetails!['contact_address'] != null &&
              clubDetails!['contact_address'].toString().isNotEmpty)
            _buildContactItem(
                Icons.location_on, clubDetails!['contact_address']),
          if (clubDetails!['facebook_link'] != null &&
              clubDetails!['facebook_link'].toString().isNotEmpty)
            _buildContactItem(Icons.facebook, clubDetails!['facebook_link']),
          if (clubDetails!['zalo_link'] != null &&
              clubDetails!['zalo_link'].toString().isNotEmpty)
            _buildContactItem(Icons.chat, 'Zalo: ${clubDetails!['zalo_link']}'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    // Kiểm tra nếu có dữ liệu thành viên
    bool hasMembers = clubDetails!['member_count'] != null &&
        int.parse(clubDetails!['member_count'].toString()) > 0;

    if (!hasMembers) {
      return Container(); // Không hiển thị nếu không có thành viên
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thành viên CLB',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_getMemberCount()} thành viên',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hiển thị danh sách các mô tả thành viên tiêu biểu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Chủ nhiệm CLB
                _buildMemberItem(
                  'Chủ nhiệm CLB',
                  clubDetails!['user']?['username'] ?? 'Chưa có thông tin',
                  const Icon(Icons.person, color: Colors.indigo),
                ),
                const Divider(height: 24),
                // Phó chủ nhiệm (giả định)
                _buildMemberItem(
                  'Phó chủ nhiệm',
                  'Chưa có thông tin',
                  const Icon(Icons.person_outline, color: Colors.indigo),
                ),
                const Divider(height: 24),
                // Thành viên tiêu biểu
                _buildMemberItem(
                  'Thư ký',
                  'Chưa có thông tin',
                  const Icon(Icons.assignment_ind, color: Colors.indigo),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Nút xem tất cả thành viên
          if (int.parse(_getMemberCount()) > 3)
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Điều hướng đến trang danh sách tất cả thành viên
                },
                icon: const Icon(Icons.group),
                label: const Text('Xem tất cả thành viên'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(String role, String name, Icon icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    List<dynamic> events = [];
    if (clubDetails!['events'] != null &&
        (clubDetails!['events'] as List).isNotEmpty) {
      events = clubDetails!['events'] as List;
    }

    if (events.isEmpty) {
      return Container(); // Không hiển thị nếu không có sự kiện
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sự kiện',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                events.length > 5 ? 5 : events.length, // Giới hạn 5 sự kiện
            itemBuilder: (context, index) {
              final event = events[index];

              // Tìm hình ảnh sự kiện
              String? eventImageUrl;
              if (event['background_images'] != null &&
                  (event['background_images'] as List).isNotEmpty) {
                eventImageUrl = event['background_images'][0]['image_url'];
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    // Điều hướng đến trang chi tiết sự kiện
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(
                          eventId: event['id'].toString(),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phần hình ảnh
                      if (eventImageUrl != null)
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(eventImageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Phần thông tin
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['name'] ?? 'Không có tên',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (event['start_date'] != null)
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 16, color: Colors.blue[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDateTime(event['start_date']),
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 4),
                            if (event['location'] != null &&
                                event['location'].toString().isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.blue[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    event['location'],
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            if (event['content'] != null)
                              Text(
                                _truncateText(event['content'], 100),
                                style: TextStyle(color: Colors.grey[800]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (events.length > 5)
            Center(
              child: TextButton(
                onPressed: () {
                  // Điều hướng đến trang danh sách tất cả sự kiện
                  // Tạm thời hiển thị message khi tính năng chưa được triển khai
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tính năng đang được phát triển'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // TODO: Implement navigation to all events when the screen is available
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => EventsListScreen(
                  //       clubId: widget.clubId,
                  //       clubName: clubDetails!['name'] ?? 'Câu lạc bộ',
                  //     ),
                  //   ),
                  // );
                },
                child: const Text('Xem tất cả sự kiện'),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Không có thời gian';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildStatistic(String value, String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getCategoryName() {
    try {
      if (clubDetails!['category'] == null) {
        return 'Học thuật, Chuyên môn';
      }

      if (clubDetails!['category'] is Map) {
        return (clubDetails!['category'] as Map)['name']?.toString() ??
            'Học thuật, Chuyên môn';
      }

      return clubDetails!['category'].toString();
    } catch (e) {
      return 'Học thuật, Chuyên môn';
    }
  }

  String _getMemberCount() {
    try {
      return (clubDetails!['member_count'] ?? '0').toString();
    } catch (e) {
      return '0';
    }
  }

  String _getEventCount() {
    try {
      if (clubDetails!['events'] != null && clubDetails!['events'] is List) {
        return (clubDetails!['events'] as List).length.toString();
      }
      return '0';
    } catch (e) {
      return '0';
    }
  }

  // Hàm để lấy mô tả an toàn
  String _getDescription() {
    try {
      if (clubDetails!['description'] == null)
        return 'Chưa có mô tả cho câu lạc bộ này.';
      return clubDetails!['description'].toString();
    } catch (e) {
      return 'Chưa có mô tả cho câu lạc bộ này.';
    }
  }

  // Widget nút đăng ký tham gia CLB
  Widget _buildJoinButton() {
    if (joinStatus == 'approved') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Đã tham gia',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (joinStatus == 'pending' || joinStatus == 'request') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Đang chờ duyệt',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isJoining ? null : _handleJoinClub,
      icon: isJoining
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.person_add, color: Colors.white),
      label: Text(
        isJoining ? 'Đang xử lý...' : 'Tham gia CLB',
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

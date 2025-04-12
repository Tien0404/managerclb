import 'package:flutter/material.dart';
import '../../../models/club_model.dart';
import '../../../services/JoinRequestService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/user_model.dart';
import '../../../routes.dart';
import '../../../utils/image_utils.dart';

class JoinedClubsScreen extends StatefulWidget {
  const JoinedClubsScreen({Key? key}) : super(key: key);

  @override
  State<JoinedClubsScreen> createState() => _JoinedClubsScreenState();
}

class _JoinedClubsScreenState extends State<JoinedClubsScreen> {
  final JoinRequestService _joinRequestService = JoinRequestService();
  bool _isLoading = true;
  List<Club> _clubs = [];
  User? _currentUser;
  String _error = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      print('DEBUG JoinClb: User data from SharedPreferences: $userString');

      if (userString != null && userString.isNotEmpty) {
        try {
          final userData = json.decode(userString);
          _currentUser = User.fromJson(userData);
          print('DEBUG JoinClb: User ID loaded: ${_currentUser?.id}');
          await _loadJoinedClubs();
        } catch (e) {
          print('DEBUG JoinClb: Error parsing user data: $e');
          setState(() {
            _error = 'Định dạng dữ liệu người dùng không hợp lệ';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Vui lòng đăng nhập để xem câu lạc bộ của bạn';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG JoinClb: Error loading user: $e');
      setState(() {
        _error = 'Không thể tải thông tin người dùng: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadJoinedClubs() async {
    if (_currentUser == null) {
      print('DEBUG JoinClb: Cannot load clubs - user is null');
      return;
    }

    try {
      print('DEBUG JoinClb: Loading clubs for user ID: ${_currentUser!.id}');
      final clubs = await _joinRequestService.getUserClubs(_currentUser!.id);
      print('DEBUG JoinClb: Loaded ${clubs.length} clubs');
      setState(() {
        _clubs = clubs;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG JoinClb: Error loading clubs: $e');
      setState(() {
        _error = 'Không thể tải danh sách câu lạc bộ: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildMemberCount(Club club) {
    return Row(
      children: [
        Icon(Icons.people, size: 16, color: Colors.indigo.shade400),
        const SizedBox(width: 4),
        Text(
          'Thành viên CLB',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(Club club) {
    Color statusColor = Colors.blue;
    String statusText = 'Hoạt động';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildClubCard(Club club) {
    // Chuyển đổi Club thành Map để có thể sử dụng với ImageUtils
    Map<String, dynamic> clubMap = {
      'id': club.id,
      'name': club.name,
      'background_images': club.backgroundImages,
      'description': club.description,
      'short_description': club.shortDescription,
      'email': club.email,
      'phone': club.phone,
      'address': club.address,
    };

    // Lấy URL ảnh từ ImageUtils
    String? clubImageUrl = ImageUtils.getClubImageUrl(clubMap);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sử dụng buildCoverImage từ ImageUtils cho ảnh bìa
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: ImageUtils.buildCoverImage(
              imageUrl: clubImageUrl,
              width: double.infinity,
              aspectRatio: 16 / 9,
              placeholder: Container(
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                ),
                child: Center(
                  child: Icon(
                    Icons.groups_rounded,
                    size: 60,
                    color: Colors.indigo.shade200,
                  ),
                ),
              ),
            ),
          ),

          // Club details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status tag and member count
                Row(
                  children: [
                    _buildStatusTag(club),
                    const Spacer(),
                    _buildMemberCount(club),
                  ],
                ),

                const SizedBox(height: 12),

                // Club name
                Text(
                  club.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Short description
                if (club.shortDescription != null &&
                    club.shortDescription!.isNotEmpty)
                  Text(
                    club.shortDescription!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),

                const SizedBox(height: 16),

                // Club gallery preview if available
                if (club.backgroundImages != null &&
                    club.backgroundImages!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hình ảnh hoạt động',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Sử dụng buildHorizontalGallery từ ImageUtils
                      ImageUtils.buildHorizontalGallery(
                        images: club.backgroundImages!,
                        height: 80,
                        spacing: 8,
                        borderRadius: BorderRadius.circular(8),
                        imageUrlExtractor: (image) =>
                            image['url'] ?? image['image_url'] ?? '',
                      ),
                    ],
                  ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Contact information
                if (club.email != null && club.email!.isNotEmpty)
                  _buildContactItem(Icons.email_outlined, club.email!),

                if (club.phone != null && club.phone!.isNotEmpty)
                  _buildContactItem(Icons.phone_outlined, club.phone!),

                if (club.address != null && club.address!.isNotEmpty)
                  _buildContactItem(Icons.location_on_outlined, club.address!),

                const SizedBox(height: 16),

                // View details button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.clubDetail,
                        arguments: club.id.toString(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Xem chi tiết',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.indigo.shade400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
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
          Icon(
            Icons.groups_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Bạn chưa tham gia câu lạc bộ nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy khám phá và tham gia các câu lạc bộ để kết nối với cộng đồng',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.clubDetail);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Khám phá câu lạc bộ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Câu lạc bộ của tôi'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadCurrentUser,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _clubs.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadJoinedClubs,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _clubs.length,
                        itemBuilder: (context, index) {
                          return _buildClubCard(_clubs[index]);
                        },
                      ),
                    ),
    );
  }
}

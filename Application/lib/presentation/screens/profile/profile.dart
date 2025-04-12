import 'package:flutter/material.dart';
import 'dart:io';
import '../../UI/footer.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer_profile.dart';
import '../../../routes.dart';
import '../../../utils/image_utils.dart';
import '../../../services/AuthService.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;

  // Thông tin người dùng đầy đủ
  Map<String, dynamic> userData = {};

  // Thông tin hiển thị
  Map<String, String> profile = {
    'image': 'https://via.placeholder.com/150', // Ảnh mặc định
    'username': 'Chưa có tên',
    'email': 'Chưa có email',
    'phone': 'Chưa có số điện thoại',
    'description': 'Chưa có mô tả',
    'id': '',
    'role': '',
    'gender': 'Không xác định',
    'email_verified': '',
    'created_at': '',
  };

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Lấy thông tin user từ SharedPreferences
  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user');

      if (userDataString != null) {
        // Parse dữ liệu
        final Map<String, dynamic> data = jsonDecode(userDataString);
        userData = data;

        // Log thông tin cụ thể
        print('==== THÔNG TIN NGƯỜI DÙNG ====');
        print('USERNAME: ${data['username']}');
        print('EMAIL: ${data['email']}');
        print('PHONE: ${data['phone']}');
        print('GENDER: ${data['gender']}');
        print('DESCRIPTION: ${data['description']}');
        print('AVATAR: ${data['avatar']}');

        // Kiểm tra và log các ảnh liên quan
        if (data['background_images'] != null) {
          print('==== HÌNH ẢNH NGƯỜI DÙNG ====');
          if (data['background_images'] is List) {
            for (var img in data['background_images']) {
              print('IMAGE URL: ${img['url'] ?? img['image_url'] ?? 'N/A'}');
            }
          } else {
            print('BACKGROUND IMAGES: ${data['background_images']}');
          }
        }

        setState(() {
          profile = {
            'image': userData['avatar'] ?? 'https://via.placeholder.com/150',
            'username': userData['username'] ?? 'Chưa có tên',
            'email': userData['email'] ?? 'Chưa có email',
            'phone': userData['phone'] ?? 'Chưa có số điện thoại',
            'description': userData['description'] ?? 'Chưa có mô tả',
            'id': userData['id']?.toString() ?? 'N/A',
            'role': userData['role']?.toString() ?? 'User',
            'gender': userData['gender']?.toString() ?? 'Không xác định',
            'email_verified': userData['email_verified'] == true
                ? 'Đã xác thực'
                : 'Chưa xác thực',
            'created_at':
                _formatDateTime(userData['created_at']?.toString() ?? ''),
          };
        });
      }
    } catch (e) {
      print('Lỗi khi tải thông tin người dùng: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _formatDateTime(String dateTimeString) {
    if (dateTimeString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateTimeString;
    }
  }

  // Kiểm tra và trả về URL hình ảnh hợp lệ
  String? _getValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // Kiểm tra xem URL có bắt đầu bằng http/https không
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // Nếu là đường dẫn tương đối, thêm base URL
    return 'https://example.com/$url'; // Thay thế bằng base URL thật của bạn
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _editField(String field) {
    TextEditingController controller =
        TextEditingController(text: profile[field]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chỉnh sửa $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nhập giá trị mới'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  profile[field] = controller.text;
                });

                // Cập nhật dữ liệu người dùng
                Map<String, dynamic> updatedData = Map.from(userData);
                updatedData[field] = controller.text;

                // Lưu thông tin mới vào SharedPreferences
                await prefs.setString('user', jsonEncode(updatedData));

                print('Đã cập nhật thông tin: $field = ${controller.text}');
                Navigator.pop(context);
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  // Xử lý lỗi khi tải hình ảnh
  Widget _buildImageWithErrorHandling(String? imageUrl, double size,
      {Widget? placeholder}) {
    // Nếu không có URL hoặc URL không hợp lệ
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl == 'https://via.placeholder.com/150') {
      return placeholder ??
          Icon(Icons.image_not_supported,
              size: size * 0.5, color: Colors.grey[400]);
    }

    return ImageUtils.buildNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: placeholder ??
          Icon(Icons.broken_image, size: size * 0.5, color: Colors.grey[400]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawerManager(),
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: buildFooter(context),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header với avatar và tên người dùng
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 30, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.indigo[600],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _image != null
                                      ? Image.file(
                                          _image!,
                                          fit: BoxFit.cover,
                                        )
                                      : _buildImageWithErrorHandling(
                                          profile['image'], 120,
                                          placeholder: Icon(Icons.person,
                                              size: 60, color: Colors.white)),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.indigo[600],
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        // Tên người dùng
                        Text(
                          profile['username']!,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 5),
                        // Vai trò
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.indigo[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            profile['role']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Thêm gallery nếu có ảnh
                  if (userData['background_images'] != null &&
                      userData['background_images'] is List &&
                      (userData['background_images'] as List).isNotEmpty)
                    _buildUserGallery(),

                  SizedBox(height: 20),

                  // Thông tin chi tiết
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[800],
                          ),
                        ),
                        SizedBox(height: 15),

                        // ID

                        // Email
                        _buildInfoCard(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          value: profile['email']!,
                          canEdit: false,
                        ),

                        // Số điện thoại
                        _buildInfoCard(
                          icon: Icons.phone_outlined,
                          title: 'Số điện thoại',
                          value: profile['phone']!,
                          canEdit: true,
                          onEdit: () => _editField('phone'),
                        ),

                        // Giới tính
                        _buildInfoCard(
                          icon: Icons.person_outline,
                          title: 'Giới tính',
                          value: profile['gender']!,
                          canEdit: false,
                        ),

                        // Ngày tạo tài khoản
                        _buildInfoCard(
                          icon: Icons.calendar_today_outlined,
                          title: 'Ngày tạo tài khoản',
                          value: profile['created_at']!,
                          canEdit: false,
                        ),

                        // Mô tả
                        _buildInfoCard(
                          icon: Icons.description_outlined,
                          title: 'Mô tả',
                          value: profile['description']!,
                          canEdit: true,
                          onEdit: () => _editField('description'),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Danh sách CLB
                  if (userData['clubs'] != null &&
                      (userData['clubs'] as List).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: _buildClubsList(),
                    ),

                  SizedBox(height: 30),

                  // Nút đăng xuất
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: ElevatedButton(
                      onPressed: () => _confirmLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 10),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // Hiển thị gallery ảnh của user nếu có
  Widget _buildUserGallery() {
    final images = userData['background_images'] as List;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ảnh của tôi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imageData = images[index];
                String? imageUrl = imageData['url'] ?? imageData['image_url'];

                return Container(
                  width: 120,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildImageWithErrorHandling(
                      imageUrl,
                      120,
                      placeholder:
                          Icon(Icons.photo, size: 40, color: Colors.grey[400]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required bool canEdit,
    VoidCallback? onEdit,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.indigo[400],
              size: 22,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (canEdit)
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.indigo[400],
                size: 20,
              ),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  Widget _buildClubsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Câu lạc bộ của tôi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: (userData['clubs'] as List).length,
          itemBuilder: (context, index) {
            final club = (userData['clubs'] as List)[index];

            // Lấy ảnh logo nếu có
            String? clubLogo;
            if (club['logo'] != null) {
              clubLogo = club['logo'];
            } else if (club['background_images'] != null &&
                club['background_images'] is List &&
                (club['background_images'] as List).isNotEmpty) {
              // Tìm ảnh logo trong background_images nếu có
              for (var img in club['background_images']) {
                if (img['is_logo'] == true) {
                  clubLogo = img['url'] ?? img['image_url'];
                  break;
                }
              }

              // Nếu không có ảnh logo, lấy ảnh đầu tiên
              if (clubLogo == null) {
                final firstImage = (club['background_images'] as List).first;
                clubLogo = firstImage['url'] ?? firstImage['image_url'];
              }
            }

            return Container(
              margin: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(15),
                leading: clubLogo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildImageWithErrorHandling(
                          clubLogo,
                          50,
                          placeholder: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                (club['name'] as String?)
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'C',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            (club['name'] as String?)
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'C',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ),
                title: Text(
                  club['name'] ?? 'Không có tên',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      club['description'] != null
                          ? _truncateText(club['description'], 80)
                          : 'Không có mô tả',
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(club['status']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusText(club['status']),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Điều hướng đến trang chi tiết CLB
                  Navigator.pushNamed(
                    context,
                    AppRoutes.clubDetail,
                    arguments: club['id'].toString(),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'active':
        return 'Hoạt động';
      case 'pending':
        return 'Chờ duyệt';
      case 'rejected':
        return 'Đã từ chối';
      default:
        return 'Không xác định';
    }
  }

  // Xác nhận đăng xuất
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog

              // Hiển thị loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );

              // Thực hiện đăng xuất
              await AuthService.logout();

              // Đóng loading dialog
              Navigator.pop(context);

              // Chuyển về màn hình đăng nhập
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../models/join_request_model.dart';
import '../../../services/JoinRequestService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/user_model.dart';

class JoinRequestListScreen extends StatefulWidget {
  const JoinRequestListScreen({Key? key}) : super(key: key);

  @override
  State<JoinRequestListScreen> createState() => _JoinRequestListScreenState();
}

class _JoinRequestListScreenState extends State<JoinRequestListScreen> {
  final JoinRequestService _joinRequestService = JoinRequestService();
  bool _isLoading = true;
  List<JoinRequest> _joinRequests = [];
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

      print(
          'DEBUG join_request: User data from SharedPreferences: $userString');

      if (userString != null && userString.isNotEmpty) {
        try {
          final userData = json.decode(userString);
          _currentUser = User.fromJson(userData);
          print('DEBUG join_request: User ID loaded: ${_currentUser?.id}');
          await _loadJoinRequests();
        } catch (e) {
          print('DEBUG join_request: Error parsing user data: $e');
          setState(() {
            _error = 'Định dạng dữ liệu người dùng không hợp lệ';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Vui lòng đăng nhập để xem yêu cầu tham gia của bạn';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG join_request: Error loading user: $e');
      setState(() {
        _error = 'Không thể tải thông tin người dùng: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadJoinRequests() async {
    if (_currentUser == null) {
      print('DEBUG join_request: Cannot load requests - user is null');
      return;
    }

    try {
      print(
          'DEBUG join_request: Loading requests for user ID: ${_currentUser!.id}');
      final requests =
          await _joinRequestService.getUserRequests(_currentUser!.id);
      print('DEBUG join_request: Loaded ${requests.length} requests');
      setState(() {
        _joinRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG join_request: Error loading requests: $e');
      setState(() {
        _error = 'Không thể tải danh sách yêu cầu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelJoinRequest(JoinRequest request) async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Canceling join request with ID: ${request.id}');
      final result = await _joinRequestService.deleteJoinRequest(request.id);

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy yêu cầu thành công'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadJoinRequests();
      } else {
        throw Exception('Không thể hủy yêu cầu');
      }
    } catch (e) {
      print('ERROR canceling join request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể hủy yêu cầu: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'request':
        return 'Đang chờ';
      case 'approved':
        return 'Đã chấp nhận';
      case 'rejected':
        return 'Bị từ chối';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'request':
        return Colors.amber;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'request':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu tham gia của tôi'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadJoinRequests();
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 64),
                      SizedBox(height: 16),
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadCurrentUser,
                        child: Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _joinRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bạn chưa gửi yêu cầu tham gia nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Quay lại'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadJoinRequests,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _joinRequests.length,
                        itemBuilder: (context, index) {
                          final request = _joinRequests[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              request.type == 'club'
                                                  ? request.club?.name ??
                                                      'Câu lạc bộ không xác định'
                                                  : request.event?.name ??
                                                      'Sự kiện không xác định',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Loại: ${request.type == 'club' ? 'Câu lạc bộ' : 'Sự kiện'}',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _getStatusColor(request.status),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getStatusIcon(request.status),
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              _getStatusText(request.status),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  if (request.message != null &&
                                      request.message!.isNotEmpty) ...[
                                    Text(
                                      'Lời nhắn:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        request.message ?? '',
                                        style:
                                            TextStyle(color: Colors.grey[800]),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (request.responseMessage != null &&
                                      request.responseMessage!.isNotEmpty) ...[
                                    Text(
                                      'Phản hồi:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: request.status == 'rejected'
                                            ? Colors.red
                                            : Colors.green[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: request.status == 'rejected'
                                            ? Colors.red[50]
                                            : Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: request.status == 'rejected'
                                              ? Colors.red[300]!
                                              : Colors.green[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        request.responseMessage ?? '',
                                        style: TextStyle(
                                          color: request.status == 'rejected'
                                              ? Colors.red[700]
                                              : Colors.green[700],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Ngày gửi: ${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (request.status == 'request')
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _cancelJoinRequest(request),
                                          icon: const Icon(Icons.cancel,
                                              color: Colors.white, size: 16),
                                          label: const Text('Hủy yêu cầu'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[400],
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            textStyle: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                    ],
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

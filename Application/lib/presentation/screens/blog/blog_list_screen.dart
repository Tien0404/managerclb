import 'package:flutter/material.dart';
import '../../../services/BlogService.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import 'package:intl/intl.dart';
import 'blog_detail_screen.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  List<dynamic> _allBlogs = [];
  List<dynamic> _displayedBlogs = [];
  bool _isLoading = true;
  String? _error;
  static const int _pageSize = 10;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final blogs = await BlogApi.fetchBlogs(forceRefresh: true);
      print('Số lượng blogs đã tải: ${blogs.length}');

      if (mounted) {
        setState(() {
          _allBlogs = blogs;
          _updateDisplayedBlogs();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _updateDisplayedBlogs() {
    if (_allBlogs.isEmpty) {
      _displayedBlogs = [];
      _hasMore = false;
      return;
    }

    final endIndex = _currentPage * _pageSize;
    print(
        'Current page: $_currentPage, Page size: $_pageSize, End index: $endIndex');
    print('Total blogs: ${_allBlogs.length}');

    if (endIndex >= _allBlogs.length) {
      _displayedBlogs = _allBlogs;
      _hasMore = false;
    } else {
      _displayedBlogs = _allBlogs.sublist(0, endIndex);
      _hasMore = true;
    }

    print('Displayed blogs: ${_displayedBlogs.length}, Has more: $_hasMore');
  }

  void _loadMore() {
    if (!_hasMore) return;
    print('Loading more blogs...');
    setState(() {
      _currentPage++;
      _updateDisplayedBlogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBlogs,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_allBlogs.isEmpty) {
      return const Center(
        child: Text('Chưa có bài viết nào'),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _currentPage = 1;
                  await _loadBlogs();
                },
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: _hasMore ? 80 : 16),
                  itemCount: _displayedBlogs.length,
                  itemBuilder: (context, index) {
                    final blog = _displayedBlogs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          blog['title'] ?? 'Không có tiêu đề',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            if (blog['background_images'] != null &&
                                blog['background_images'] is List &&
                                blog['background_images'].isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  blog['background_images'][0]['image_url'],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              blog['content'] ?? 'Không có nội dung',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(blog['created_at']),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BlogDetailScreen(blogId: blog['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        if (_hasMore)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _loadMore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'XEM THÊM BÀI VIẾT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Không có ngày';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return 'Ngày không hợp lệ';
    }
  }
}

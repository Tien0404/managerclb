import 'package:flutter/material.dart';
import '../../../services/BlogService.dart';
import 'blog_card.dart';

class BlogList extends StatefulWidget {
  @override
  _BlogListState createState() => _BlogListState();
}

class _BlogListState extends State<BlogList> {
  late Future<List<dynamic>> _blogsFuture;

  @override
  void initState() {
    super.initState();
    _blogsFuture = BlogApi.fetchBlogs().then((blogs) {
      print('Số lượng blog đã tải: ${blogs.length}');
      if (blogs.isNotEmpty) {
        print('Blog đầu tiên: ${blogs[0]}');
        print('Các khóa trong blog: ${blogs[0].keys.toList()}');

        // Kiểm tra nếu blog có trường club
        if (blogs[0]['club'] != null) {
          print('Thông tin club: ${blogs[0]['club']}');
          if (blogs[0]['club'] is Map) {
            print('Các khóa trong club: ${blogs[0]['club'].keys.toList()}');
          }
        }

        // Kiểm tra nếu blog có trường author
        if (blogs[0]['author'] != null) {
          print('Thông tin author: ${blogs[0]['author']}');
        }

        // Kiểm tra nếu blog có trường content hoặc description
        if (blogs[0]['content'] != null) {
          print('Blog có trường content');
        }
        if (blogs[0]['description'] != null) {
          print('Blog có trường description');
        }
      }
      return blogs;
    }).catchError((e) {
      print('Lỗi khi tải blog: $e');
      throw e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _blogsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Lỗi khi tải blog!"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Không có bài viết nào."));
        }

        final blogs = snapshot.data!;
        return ListView.builder(
          itemCount: blogs.length,
          itemBuilder: (context, index) {
            return BlogCard(blog: blogs[index]);
          },
        );
      },
    );
  }
}

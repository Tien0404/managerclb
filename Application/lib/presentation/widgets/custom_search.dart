import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildSectionTitle('Phù hợp với bạn!'),
          const SizedBox(height: 10),
          _buildCategoryList([
            'Học thuật',
            'Chuyên Nghệ thuật',
            'Sáng Truyền thông',
            'Báo trí Thể thao',
            'Sức khỏe',
          ]),
          const SizedBox(height: 20),
          _buildSectionTitle('Môn tạo'),
          const SizedBox(height: 10),
          _buildCategoryList([
            'Kỹ năng',
            'Giá trị Tình nguyện',
            'Công Ngoại ngữ',
            'Văn hóa Thể thao',
            'Giải trí',
          ]),
        ],
      ),
    );
  }

  // Xây dựng thanh tìm kiếm
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm Câu Lạc Bộ',
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng tiêu đề section
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // Xây dựng danh sách danh mục
  Widget _buildCategoryList(List<String> categories) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: categories.map((category) => _buildCategory(category)).toList(),
    );
  }

  // Xây dựng một danh mục
  Widget _buildCategory(String title) {
    return InkWell(
      onTap: () {
        // Xử lý khi bấm vào danh mục
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
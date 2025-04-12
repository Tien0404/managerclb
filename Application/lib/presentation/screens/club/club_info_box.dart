import 'package:flutter/material.dart';
import '../../../utils/image_utils.dart';

class ClubInfoBox extends StatelessWidget {
  final String title;
  final String description;
  final String location;
  final int members;
  final String imageUrl;
  final VoidCallback onDetailsPressed; // Thêm callback này

  const ClubInfoBox({
    required this.title,
    required this.description,
    required this.location,
    required this.members,
    required this.imageUrl,
    required this.onDetailsPressed, // Thêm callback này
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh của CLB
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageUtils.buildNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            // Tiêu đề
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Mô tả
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // Địa điểm và số thành viên
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Spacer(),
                Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '$members thành viên',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Nút "Chi tiết"
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onDetailsPressed, // Sử dụng callback
                child: const Text(
                  'Quản Lý',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

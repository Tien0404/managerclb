import 'package:flutter/material.dart';
import '../../../routes.dart'; // Import file routes.dart
import 'member_detail_screen.dart';
import 'member_form_screen.dart';

class MemberListScreen extends StatelessWidget {
  final List<String> members = [
    'Thành viên A',
    'Thành viên B',
    'Thành viên C'
  ]; // Danh sách thành viên mẫu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Danh sách Thành viên'),
        automaticallyImplyLeading: false, // Ẩn nút "Trở lại" mặc định
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Điều hướng đến màn hình HomeScreen
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(members[index]),
            onTap: () {
              // Điều hướng đến màn hình chi tiết thành viên với tham số memberId
              Navigator.pushNamed(
                context,
                AppRoutes.memberDetail,
                arguments: members[index], // Truyền memberId làm tham số
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Điều hướng đến màn hình thêm/sửa thành viên
          Navigator.pushNamed(context, AppRoutes.memberForm);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

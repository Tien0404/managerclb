import 'package:flutter/material.dart';

class MemberFormScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Thêm/Sửa Thành viên')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tên Thành viên'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Xử lý lưu thông tin thành viên
                final name = _nameController.text;
                final email = _emailController.text;
                print('Tên Thành viên: $name, Email: $email');
                Navigator.pop(context);
              },
              child: Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
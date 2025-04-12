import 'package:flutter/material.dart';

class ClubFormScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Thêm/Sửa Club')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tên Club'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Mô tả'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Xử lý lưu thông tin club
                final name = _nameController.text;
                final description = _descriptionController.text;
                print('Tên Club: $name, Mô tả: $description');
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
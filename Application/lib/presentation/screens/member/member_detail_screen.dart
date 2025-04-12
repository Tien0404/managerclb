import 'package:flutter/material.dart';

class MemberDetailScreen extends StatelessWidget {
  final String memberId;

  MemberDetailScreen({required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Chi tiết Thành viên')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Thành viên ID: $memberId'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../UI/footer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import 'blog_list.dart';

class BlogExplorer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: BlogList(),
      bottomNavigationBar: buildFooter(context),
    );
  }
}

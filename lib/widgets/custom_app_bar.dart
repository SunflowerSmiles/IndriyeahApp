import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const CustomAppBar({
    super.key,
    required this.height,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Text(
        "indri.yeah",
        style: TextStyle(
          fontSize: 30,
          color: Colors.pink.shade900,
        ),
      ),
    );
  }
}

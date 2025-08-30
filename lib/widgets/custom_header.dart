import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? userName;

  const CustomHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(color: Colors.grey),
                ),
              if (userName != null)
                Text(
                  "Hi, $userName",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, color: Colors.green),
                ),
            ],
          ),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
// import 'package:asman_toga/helper/prefs.dart';
// import 'package:asman_toga/service/api_service.dart';
// import 'package:asman_toga/pages/plant_detail_page_admin.dart';

import 'users_tab.dart';
import 'plants_tab.dart';
import 'dashboard_tab.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [DashboardTab(), UsersTab(), PlantsTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF57A32E), 
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: "Plants"),
        ],
      ),
    );
  }
}

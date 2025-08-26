import 'package:asman_toga/helper/prefs.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // tambahin ini

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Delay splash

    
    final token = await PrefsHelper.getToken();
    debugPrint("TOKEN: $token");

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // biar rata tengah
          children: [
            Image.asset("assets/logo_gunaksa.png", height: 120.h), 
            SizedBox(width: 20.w), // jarak antar logo
            Image.asset("assets/logo.png", height: 120.h),
          ],
        ),
      ),
    ),
  );
}

}

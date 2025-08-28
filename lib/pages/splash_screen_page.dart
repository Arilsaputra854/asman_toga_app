import 'package:asman_toga/helper/prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Fade in
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _opacity = 1.0);

    // Tahan sebentar
    await Future.delayed(const Duration(seconds: 4));

    // Fade out
    setState(() => _opacity = 0.0);

    // Tunggu fade out selesai
    await Future.delayed(const Duration(milliseconds: 1500));

    // Cek login setelah animasi
    final token = await PrefsHelper.getToken();
    debugPrint("TOKEN: $token");

    if (!mounted) return;
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
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logo_gunaksa.png", height: 120.h),
                SizedBox(width: 20.w),
                Image.asset("assets/logo_title.png", height: 120.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

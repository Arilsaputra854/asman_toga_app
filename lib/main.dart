import 'package:asman_toga/pages/admin_dashboard.dart';
import 'package:asman_toga/pages/forgot_password_page.dart';
import 'package:asman_toga/pages/home_page.dart';
import 'package:asman_toga/pages/login_page.dart';
import 'package:asman_toga/pages/otp_page.dart';
import 'package:asman_toga/pages/plants_page.dart';
import 'package:asman_toga/pages/profile_page.dart';
import 'package:asman_toga/pages/register_page.dart';
import 'package:asman_toga/pages/reset_password_page.dart';
import 'package:asman_toga/pages/splash_screen_page.dart';
import 'package:asman_toga/viewmodel/create_userplant_admin_viewmodel.dart';
import 'package:asman_toga/viewmodel/home_viewmodel.dart';
import 'package:asman_toga/viewmodel/login_viewmodel.dart';
import 'package:asman_toga/viewmodel/profile_viewmodel.dart';
import 'package:asman_toga/viewmodel/register_viewmodel.dart';
import 'package:asman_toga/viewmodel/tambah_lokasi_tanaman_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => TambahLokasiTanamanViewModel()),
        ChangeNotifierProvider(create: (_) => CreateUserplantAdminViewmodel()),
      ],
      child: MaterialApp(
        title: 'Asman Toga',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Roboto'),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/register': (context) => const RegisterPage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => const HomePage(),
          '/profile': (context) => const ProfilePage(),
          '/plants': (context) => const PlantsPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/otp': (context) => const OtpPage(),
          '/reset-password': (context) => const ResetPasswordPage(),
          '/admin-dashboard': (context) => const AdminDashboardPage(),
        },
      ),
    );
  }
}

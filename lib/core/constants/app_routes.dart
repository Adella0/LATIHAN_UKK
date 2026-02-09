import 'package:apk_peminjaman/features/admin/ui/main_nav_admin.dart';
import 'package:apk_peminjaman/features/peminjam/ui/main_nav_peminjam.dart';
import 'package:flutter/material.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/splash_screen.dart';

class AppRoutes {
  // Rute awal (biasanya Splash Screen atau Login)
  static const String initial = '/login'; 

  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/main_peminjam': (context) => const MainNavPeminjam(), // Induk Navigasi Peminjam
    '/main_admin': (context) => const MainNavAdmin(),       // Induk Navigasi Admin
    // '/splash': (context) => const SplashScreen(),        // Tambahkan jika ingin dipakai
  }; // <--- Jangan lupa titik koma di sini
}
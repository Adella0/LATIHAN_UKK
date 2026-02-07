import 'package:flutter/material.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/admin/ui/main_nav_admin.dart'; // Import MainNavAdmin kamu
import '../../features/petugas/dashboard/dashboard_petugas_screen.dart';
import '../../features/peminjam/dashboard/dashboard_peminjam_screen.dart';

class AppRoutes {
  // Tambahkan baris ini
  static const String initial = '/'; 

  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/dashboard_admin': (context) => const MainNav(),
    '/dashboard_petugas': (context) => const DashboardPetugasScreen(),
    '/dashboard_peminjam': (context) => const DashboardPeminjamScreen(),
  };
}
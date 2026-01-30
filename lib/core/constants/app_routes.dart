import 'package:flutter/material.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/admin/dashboard/dashboard_admin_screen.dart';
import '../../features/petugas/dashboard/dashboard_petugas_screen.dart';
import '../../features/peminjam/dashboard/dashboard_peminjam_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/dashboard_admin': (context) => const DashboardAdminScreen(),
    '/dashboard_petugas': (context) => const DashboardPetugasScreen(),
    '/dashboard_peminjam': (context) => const DashboardPeminjamScreen(),
  };
}
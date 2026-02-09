import 'package:apk_peminjaman/features/admin/ui/main_nav_admin.dart';
import 'package:apk_peminjaman/features/peminjam/ui/main_nav_peminjam.dart';
import 'package:apk_peminjaman/features/petugas/ui/main_nav_petugas.dart';
import 'package:apk_peminjaman/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRoutes {
  // Ubah initial ke '/' agar AuthGate yang pertama kali jalan
  static const String initial = '/'; 

  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const AuthGate(), // Satpam pengecek Role
    '/login': (context) => const LoginScreen(),
    '/main_peminjam': (context) => const MainNavPeminjam(),
    '/main_admin': (context) => const MainNavAdmin(),  
    '/main_petugas': (context) => const MainNavPetugas(),
  };
}

// Tambahkan class AuthGate di bawah AppRoutes (atau buat file terpisah)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    // Jika belum login, lempar ke halaman login
    if (session == null) {
      return const LoginScreen();
    }

    // Jika sudah login, cek role di database
    return FutureBuilder(
      future: Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id_user', session.user.id)
          .single(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final role = snapshot.data!['role'];
          // Arahkan sesuai role
          if (role == 'petugas') return const MainNavPetugas();
          if (role == 'admin') return const MainNavAdmin();
          return const MainNavPeminjam(); 
        }

        // Jika data user tidak ditemukan di tabel users, suruh login ulang
        return const LoginScreen();
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
  await Future.delayed(const Duration(seconds: 4)); // Delay splash screen
  
  final session = Supabase.instance.client.auth.currentSession;

  if (session != null) {
    try {
      // Ambil role dari tabel users
      final userData = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id_user', session.user.id)
          .single();

      if (mounted) {
        String role = userData['role'].toString().toLowerCase().trim();
        // Langsung arahkan ke dashboard yang sesuai (termasuk peminjam)
        Navigator.pushReplacementNamed(context, '/dashboard_$role');
      }
    } catch (e) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  } else {
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'asset/image/sarpras.png', // Sesuaikan dengan folder 'asset' kamu
          width: 250,
        ),
      ),
    );
  }
}
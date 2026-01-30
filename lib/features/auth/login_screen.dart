import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  // Fungsi Login logic
 // Cari bagian _handleLogin() dan pastikan logikanya seperti ini:
Future<void> _handleLogin() async {
  // ... (kode validasi email/pass tetap sama) ...

  setState(() => _isLoading = true);
  try {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final user = response.user;
    if (user != null) {
      // Ambil data role
      final responseData = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id_user', user.id);

      if (responseData.isNotEmpty) {
        // Normalisasi teks role (huruf kecil & tanpa spasi)
        String roleFromDb = responseData[0]['role'].toString().trim().toLowerCase();
        
        if (mounted) {
          // Navigasi dinamis: akan ke /dashboard_admin, /dashboard_petugas, atau /dashboard_peminjam
          Navigator.pushReplacementNamed(context, '/dashboard_$roleFromDb');
        }
      } else {
        throw "User terdaftar di Auth, tapi data di tabel 'users' tidak ditemukan. Cek UUID di database.";
      }
    }
  } catch (e) {
    // ... (kode snackbar error tetap sama)
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          children: [
            const SizedBox(height: 120),
            // Sesuai folder kamu 'asset/image/'
            Image.asset('asset/image/sarpras.png', height: 180),
            const SizedBox(height: 60),
            
            // Field Email
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Masukkan email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), 
              ),
            ),
            
            const SizedBox(height: 25),
            
            // Field Password
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                hintText: "Masukkan password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), 
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Tombol Login
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // SEKARANG SUDAH TERHUBUNG KE FUNGSI LOGIN
                onPressed: _isLoading ? null : _handleLogin, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02182F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text(
                      "Login", 
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
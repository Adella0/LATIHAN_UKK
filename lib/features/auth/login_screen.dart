import 'package:apk_peminjaman/features/petugas/ui/main_nav_petugas.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../peminjam/ui/main_nav_peminjam.dart';
import '../admin/ui/main_nav_admin.dart';

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

  final Color _primaryDark = const Color(0xFF02182F);

  // Fungsi Notifikasi Modern (SnackBar Custom)
  void _showNotification({required String title, required String message, bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isError ? const Color(0xFFC72C41) : const Color(0xFF2D6A4F),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 35,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      message,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi Input Kosong
    if (email.isEmpty || password.isEmpty) {
      _showNotification(
        title: "Input Tidak Lengkap",
        message: "Silahkan masukkan email dan password Anda.",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        final responseData = await Supabase.instance.client
            .from('users')
            .select('role')
            .eq('id_user', user.id)
            .maybeSingle();

        if (responseData != null && responseData['role'] != null) {
          String roleFromDb = responseData['role'].toString().trim().toLowerCase();
          
          if (mounted) {
            if (roleFromDb == 'admin') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavAdmin()));
            } else if (roleFromDb == 'peminjam') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavPeminjam()));
            } else if (roleFromDb == 'petugas') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavPetugas()));
            } else {
              throw "Role tidak dikenali";
            }
          }
        } else {
          throw "Data profil tidak ditemukan.";
        }
      }
    } on AuthException catch (e) {
      // 2. Validasi Email/Password Salah (Spesifik Supabase)
      if (mounted) {
        String errorText = "Terjadi kesalahan login.";
        if (e.message.contains("Invalid login credentials")) {
          errorText = "Email atau password yang Anda masukkan salah.";
        }
        _showNotification(
          title: "Login Gagal",
          message: errorText,
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showNotification(
          title: "Error",
          message: "Koneksi bermasalah atau server error.",
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue.shade50.withOpacity(0.5)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'asset/image/sarpras.png', 
                  height: 160,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Selamat Datang",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark,
                ),
              ),
              Text(
                "Silahkan login untuk melanjutkan",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 50),
              _buildInputLabel("Email"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: "user@mail.com",
                icon: Icons.email_outlined,
                type: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildInputLabel("Password"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                hint: "••••••••",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscure: _isObscure,
                onToggle: () => setState(() => _isObscure = !_isObscure),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDark,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: _primaryDark.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          "Masuk Sekarang",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _primaryDark.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
        keyboardType: type,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: _primaryDark.withOpacity(0.6), size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey, size: 20,
                  ),
                  onPressed: onToggle,
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _primaryDark, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
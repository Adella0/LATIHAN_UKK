import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apk_peminjaman/features/auth/login_screen.dart'; 

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase
            .from('users')
            .select()
            .eq('id_user', user.id)
            .single();
        setState(() {
          userData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetch profil: $e");
    }
  }

  // --- FUNGSI DIALOG LOGOUT (SESUAI GAMBAR) ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Logout?",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Apakah kamu yakin ingin keluar dari akun?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    // Tombol Tidak
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context), // Tutup Dialog
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9D0D6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          "Tidak",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF02182F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Tombol Iya
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await supabase.auth.signOut();
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF02182F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          "Iya",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFFC9D0D6),
                      child: Icon(Icons.person, size: 80, color: Color(0xFF6C757D)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Hallo, ${userData?['nama'] ?? 'User'}!",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userData?['role'] ?? 'Role',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF6C757D),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildProfileField("Nama", userData?['nama'], Icons.person_outline),
                  _buildProfileField("Email", supabase.auth.currentUser?.email, Icons.email_outlined),
                  _buildProfileField("Password", "**********", Icons.lock_outline),
                  _buildProfileField("Sebagai", userData?['role'], Icons.assignment_ind_outlined),

                  const SizedBox(height: 50),

                  // Tombol Logout memanggil _showLogoutDialog
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _showLogoutDialog, // Panggil Dialog di sini
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02182F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileField(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value ?? "",
            readOnly: true,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF02182F)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
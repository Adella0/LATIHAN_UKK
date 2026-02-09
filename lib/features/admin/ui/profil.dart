import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Mengambil data user yang sedang login
  Future<void> _loadUserData() async {
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
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Dialog Logout Sesuai Desain
 void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4), // Overlay lebih soft
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFEBE6ED), // Warna ungu muda sesuai gambar
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Logout?",
              style: GoogleFonts.poppins(
                fontSize: 22, 
                fontWeight: FontWeight.w800, // Lebih tebal
                color: const Color(0xFF02182F),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Apakah kamu yakin ingin keluar dari akun?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14, 
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                // Tombol Tidak
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0E0E0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "Tidak", 
                          style: GoogleFonts.poppins(
                            color: Colors.black, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Tombol Iya
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          await supabase.auth.signOut();
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF02182F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "Iya", 
                          style: GoogleFonts.poppins(
                            color: Colors.white, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Profil", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFFBDC3C7),
                      child: Icon(Icons.person, size: 80, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Hallo, ${userData?['nama'] ?? 'User'}!",
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(userData?['role'] ?? '-',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 40),

                  // Field Profile (ReadOnly)
                  _buildProfileField("Nama", userData?['nama']),
                  _buildProfileField("Email", userData?['email']),
                  _buildProfileField("Password", "**********"), // Password disembunyikan
                  _buildProfileField("Sebagai", userData?['role']),

                  const SizedBox(height: 50),

                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text("Logout", 
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02182F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value ?? '-',
            readOnly: true, // Membuat tidak bisa diedit
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ],
      ),
    );
  }
}
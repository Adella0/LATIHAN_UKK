import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import semua halaman yang dibutuhkan
import '../dashboard/dashboard_admin_screen.dart';
import '../manage_alat/list_alat_screen.dart';
import '../manage_user/List_pengguna.dart';
import '../dashboard/daftar_riwayat_aktivitas.dart';

class MainNavAdmin extends StatefulWidget {
  const MainNavAdmin({super.key});

  @override
  State<MainNavAdmin> createState() => _MainNavAdminState();
}

class _MainNavAdminState extends State<MainNavAdmin> {
  // Pindahkan logika index ke sini
  int _selectedIndex = 0;

  // List halaman yang akan dipanggil sesuai urutan icon di navbar
  final List<Widget> _pages = [
    const DashboardAdminScreen(),
    const ListAlatScreen(),
    const ListPenggunaScreen(),
    const DaftarRiwayatAktivitas(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF02182F);

    return Scaffold(
      backgroundColor: Colors.white,
      // SafeArea ditaruh di sini agar konten tidak tertutup notch HP
      body: SafeArea(
        bottom: false, // Supaya konten bisa sedikit "tembus" ke belakang navbar
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      extendBody: true, // PENTING: Supaya navbar melengkung tidak memotong body
      bottomNavigationBar: _buildBottomNav(primaryBlue),
    );
  }

  // --- Ambil fungsi _buildBottomNav dari dashboard Anda tadi dan pindahkan ke sini ---
  Widget _buildBottomNav(Color blue) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 10), 
      height: 80, 
      decoration: BoxDecoration(
        color: blue, 
        borderRadius: BorderRadius.circular(40), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, "Dashboard", 0),
          _buildNavItem(Icons.inventory_2, "Alat", 1),
          _buildNavItem(Icons.people, "Pengguna", 2),
          _buildNavItem(Icons.description, "Aktivitas", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index; 
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28), 
          const SizedBox(height: 4),
          Text(
            label, 
            style: GoogleFonts.poppins(
              color: Colors.white, 
              fontSize: 10, 
              fontWeight: isActive ? FontWeight.bold : FontWeight.w400
            )
          ), 
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2.5,
              width: 30,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
            )
          else
            const SizedBox(height: 6.5), 
        ],
      ),
    );
  }
}
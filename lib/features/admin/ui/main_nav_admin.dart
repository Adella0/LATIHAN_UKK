import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard/dashboard_admin_screen.dart';
import '../manage_alat/list_alat_screen.dart';
import '../manage_user/List_pengguna.dart';

class MainNavAdmin extends StatefulWidget {
  const MainNavAdmin({super.key});

  @override
  State<MainNavAdmin> createState() => _MainNavAdminState();
}

class _MainNavAdminState extends State<MainNavAdmin> {
  int _selectedIndex = 0;
  final Color primaryBlue = const Color(0xFF02182F);

  // Daftar halaman yang ditampilkan
  final List<Widget> _pages = [
    const DashboardAdminScreen(),
    const ListAlatScreen(),
    const ListPenggunaScreen(),
    const Center(child: Text("Halaman Data Peminjam")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // extendBody: true agar konten bisa mengisi ruang di belakang navbar yang melayang
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      // Margin disesuaikan agar melayang cantik seperti di gambar
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 12),
      height: 75,
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(40), // Sudut sangat membulat (Capsule style)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Jarak antar item merata
        children: [
          _buildNavItem(Icons.home, "Dashboard", 0),
          _buildNavItem(Icons.inventory_2, "Alat", 1),
          _buildNavItem(Icons.people, "Pengguna", 2),
          _buildNavItem(Icons.manage_search, "Peminjam", 3),
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
      behavior: HitTestBehavior.opaque, // Menambah hitTest agar mudah diklik
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          // Indikator garis bawah putih saat aktif
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(height: 6), // Penjaga agar tata letak tidak melompat
        ],
      ),
    );
  }
}
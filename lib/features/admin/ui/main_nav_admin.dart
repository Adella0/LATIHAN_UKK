import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard/dashboard_admin_screen.dart'; // Sesuaikan path dashboard Anda
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

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const DashboardAdminScreen(),
    const ListAlatScreen(),
    const ListPenggunaScreen(),
    const Center(child: Text("Halaman Ringkasan Aktivitas")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Menggunakan IndexedStack agar state halaman (scroll, data) tidak reset saat pindah tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 20), // Jarak bawah ditambah agar tidak terlalu mepet
      height: 80,
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
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
          Icon(icon, color: Colors.white, size: 28), // Diperkecil sedikit agar proporsional
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2.5,
              width: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(height: 6.5),
        ],
      ),
    );
  }
}
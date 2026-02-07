import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard/dashboard_admin_screen.dart';
import '../manage_alat/list_alat_screen.dart';

class MainNavAdmin extends StatefulWidget {
  const MainNavAdmin({super.key});

  @override
  State<MainNavAdmin> createState() => _MainNavAdminState();
}

class _MainNavAdminState extends State<MainNavAdmin> {
  int _selectedIndex = 0;

  // 2. MASUKKAN CLASS DARI list_alat_screen.dart KE INDEX KE-1
  late final List<Widget> _pages = [
    const DashboardAdminScreen(),
    const ListAlatScreen(), // <--- GANTI DI SINI (Pastikan namanya sesuai dengan class di file list_alat_screen)
    const Center(child: Text("Halaman Pengguna")), 
    const Center(child: Text("Halaman Data Peminjam")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan IndexedStack agar halaman tidak ter-reset saat pindah tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavbar(),
    );
  }

 Widget _buildBottomNavbar() {
  return Container(
    // Tinggi diturunkan agar tidak terlalu bongsor
    height: 70, 
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
        top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _navItem(0, Icons.home, "Dashboard"),
        _navItem(1, Icons.inventory_2_rounded, "Alat"),
        _navItem(2, Icons.people_rounded, "Pengguna"),
        _navItem(3, Icons.manage_search_rounded, "Data peminjam"),
      ],
    ),
  );
}

Widget _navItem(int index, IconData icon, String label) {
  bool isActive = _selectedIndex == index;
  return Expanded(
    child: InkWell(
      onTap: () => _onItemTapped(index),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isActive ? const Color(0xFF02182F) : Colors.black45,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? const Color(0xFF02182F) : Colors.black45,
            ),
          ),
        ],
      ),
    ),
  );
}
}
import 'package:apk_peminjaman/features/admin/manage_user/List_pengguna.dart';
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

  // 2. Masukkan DashboardAdminScreen ke index 0
  final List<Widget> _pages = [
    const DashboardAdminScreen(),                            // Dashboard Asli Muncul Lagi
    const ListAlatScreen(),                                  // Menu Alat
    const ListPenggunaScreen(),
    const Center(child: Text("Halaman Data Peminjaman")),    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF02182F),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11, 
            fontWeight: FontWeight.w600
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), 
              label: 'Dashboard'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded), 
              label: 'Alat'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded), 
              label: 'Pengguna'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded), 
              label: 'Peminjaman'
            ),
          ],
        ),
      ),
    );
  }
}
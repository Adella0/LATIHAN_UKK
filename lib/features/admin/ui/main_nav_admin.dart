
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../manage_alat/list_alat_screen.dart';// Ganti dengan nama file list alatmu
import '../manage_alat/tambah_alat.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0;

  // List halaman utama
  final List<Widget> _pages = [
    const ListAlatScreen(), // Halaman Index 0
    const Center(child: Text("Halaman Peminjaman")), // Index 1
    const Center(child: Text("Halaman Profile")),    // Index 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      
      // TOMBOL TAMBAH BULAT (Floating Action Button)
      // Ini yang akan masuk ke tambah_alat.dart
      floatingActionButton: _selectedIndex == 0 
          ? FloatingActionButton(
              onPressed: () async {
                // KUNCINYA: Pakai 'await' untuk menunggu hasil dari halaman tambah
                final bool? BerhasilTambah = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TambahAlatScreen()),
                );

                // Jika kembali membawa nilai 'true', maka refresh halaman
                if (BerhasilTambah == true) {
                  setState(() {
                    // Refresh state untuk memicu FutureBuilder di ListAlat
                  });
                }
              },
              backgroundColor: const Color(0xFF02182F),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,

      // DESIGN BOTTOM NAV
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
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
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Pinjam',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
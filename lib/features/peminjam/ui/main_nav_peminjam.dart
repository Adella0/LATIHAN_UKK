import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard/dashboard_peminjam_screen.dart'; // Sesuaikan path ini
import '../pinjaman/pinjaman_saya.dart';   // Sesuaikan path ini
import '../riwayat/riwayat_pinjaman.dart';

class MainNavPeminjam extends StatefulWidget {
  const MainNavPeminjam({super.key});

  @override
  State<MainNavPeminjam> createState() => _MainNavPeminjamState();
}

class _MainNavPeminjamState extends State<MainNavPeminjam> {
  int _selectedIndex = 0;

  // Daftar halaman untuk Peminjam
  final List<Widget> _pages = [
    const DashboardPeminjamScreen(), 
    const PinjamanSayaScreen(), 
    const RiwayatPeminjamanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        // Menambahkan lengkungan di sudut atas navbar sesuai gambar
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF02182F), // Biru gelap sesuai tema
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11, 
              fontWeight: FontWeight.w600
            ),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_rounded, size: 25), // Ikon Dashboard
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.shopping_cart_checkout_rounded, size: 25), // Ikon Pinjaman Saya (mirip troli di gambar)
                ),
                label: 'Pinjaman saya',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.history_rounded, size: 25), // Ikon Riwayat
                ),
                label: 'Riwayat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
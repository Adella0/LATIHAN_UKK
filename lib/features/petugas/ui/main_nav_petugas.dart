import 'package:apk_peminjaman/features/petugas/dashboard/dashboard_petugas_screen.dart';
import 'package:apk_peminjaman/features/petugas/pengembalian/list_pengembalian.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../persetujuan/form_persetujuan.dart';

class MainNavPetugas extends StatefulWidget {
  const MainNavPetugas({super.key});

  @override
  State<MainNavPetugas> createState() => _MainNavPetugasState();
}

class _MainNavPetugasState extends State<MainNavPetugas> {
  int _selectedIndex = 0;

  // Daftar halaman untuk Petugas (Sesuaikan dengan Class Screen Anda)
  final List<Widget> _pages = [
    const DashboardPetugasScreen(),// Ganti dengan DashboardPetugasScreen()
    const FormPersetujuan(),
    const ListPengembalian()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
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
              fontSize: 10, // Sedikit lebih kecil karena ada 4 item
              fontWeight: FontWeight.w600
            ),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_filled, size: 26),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.verified_rounded, size: 26), // Ikon Persetujuan (Badge check)
                ),
                label: 'Persetujuan',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.assignment_return_rounded, size: 26), // Ikon Pengembalian
                ),
                label: 'Pengembalian',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.bar_chart_rounded, size: 26), // Ikon Laporan (Chart)
                ),
                label: 'Laporan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DaftarRiwayatAktivitas extends StatelessWidget {
  const DaftarRiwayatAktivitas({super.key});

  // --- FUNGSI POP-UP DETAIL (TETAP SAMA) ---
  void _showActivityDetail(BuildContext context, String nama, String tanggal, String role, Color badgeColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF424242),
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
                        child: Text(role, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Text("Tanggal : $tanggal", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 30),
            Text("Aktivitas", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF02182F))),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role == "Petugas" 
                    ? "Menyetujui peminjaman alat\n1 proyektor" 
                    : "Melakukan peminjaman alat\n1 proyektor",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF02182F);
    const Color searchGrey = Color(0xFFC9D0D6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40), // Ukuran disesuaikan agar tidak terlalu jauh ke bawah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                 // Di dalam daftar_riwayat_aktivitas.dart
GestureDetector(
  onTap: () {
    Navigator.pop(context); // Menutup halaman riwayat dan kembali ke stack sebelumnya (Dashboard)
  },
  child: Container(
    padding: const EdgeInsets.all(8),
    decoration: const BoxDecoration(
      color: Color(0xFF02182F), // Background lingkaran biru
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.arrow_back_ios_new,
      color: Colors.white,
      size: 18,
    ),
  ),
),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Detail riwayat",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Spacer penyeimbang tombol back
                ],
              ),
            ),
            const SizedBox(height: 45),
            // --- BAGIAN SEARCH DAN LIST TETAP SAMA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: searchGrey,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari...",
                    hintStyle: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 20),
                children: [
                  _buildHistoryCard(context, "Ailen", "12/01/2026", "Petugas", primaryBlue),
                  _buildHistoryCard(context, "Monica", "12/01/2026", "Peminjam", const Color(0xFFADB5BD)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, String nama, String tanggal, String role, Color badgeColor) {
    return GestureDetector(
      onTap: () => _showActivityDetail(context, nama, tanggal, role, badgeColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15), 
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 70, child: Text("Nama", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
                      const Text(":   ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(nama, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
                        child: Text(role, style: GoogleFonts.poppins(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(width: 70, child: Text("Tanggal", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
                      const Text(":   ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(tanggal, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
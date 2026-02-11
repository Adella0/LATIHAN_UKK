import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiwayatPeminjamanScreen extends StatefulWidget {
  const RiwayatPeminjamanScreen({super.key});

  @override
  State<RiwayatPeminjamanScreen> createState() => _RiwayatPeminjamanScreenState();
}

class _RiwayatPeminjamanScreenState extends State<RiwayatPeminjamanScreen> {
  final Color _primaryDark = const Color(0xFF02182F);
  final Color _bgLight = const Color(0xFFF8FAFC);
  final Color _softGrey = const Color(0xFFE2E8F0);

  final List<Map<String, dynamic>> _riwayatData = [
    {
      'nama': 'Monica',
      'tanggal': '12/01/2026',
      'status': 'Ditolak',
      'color': const Color(0xFFE52121),
    },
    {
      'nama': 'Monica',
      'tanggal': '12/01/2026',
      'status': 'Selesai',
      'color': const Color(0xFF02182F), // Diubah ke Primary Dark agar senada
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildHeader(),
            const SizedBox(height: 25),
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                itemCount: _riwayatData.length,
                itemBuilder: (context, index) {
                  return _buildRiwayatCard(_riwayatData[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      "Riwayat",
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _primaryDark,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Cari riwayat peminjaman...",
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: _primaryDark),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Aksi ke detail
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar Inisial atau Ikon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _primaryDark.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.history_edu_rounded, color: _primaryDark),
                ),
                const SizedBox(width: 15),
                // Informasi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['nama'],
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['tanggal'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: data['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        data['status'],
                        style: GoogleFonts.poppins(
                          color: data['color'],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _softGrey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
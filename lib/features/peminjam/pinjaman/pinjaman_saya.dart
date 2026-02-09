import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PinjamanSayaScreen extends StatefulWidget {
  const PinjamanSayaScreen({super.key});

  @override
  State<PinjamanSayaScreen> createState() => _PinjamanSayaScreenState();
}

class _PinjamanSayaScreenState extends State<PinjamanSayaScreen> {
  // Data dummy untuk tampilan sesuai gambar
  final List<Map<String, dynamic>> _pinjamanData = [
    {'nama': 'Monica', 'tanggal': '12/01/2026', 'status': 'Aktif', 'color': const Color(0xFF1ED72D)},
    {'nama': 'Monica', 'tanggal': '12/01/2026', 'status': 'Terlambat', 'color': const Color(0xFFE52121)},
    {'nama': 'Monica', 'tanggal': '12/01/2026', 'status': 'Pending', 'color': const Color(0xFF02182F)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Judul Halaman
            Center(
              child: Text(
                "Aktivitas",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF02182F),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Search Bar sesuai desain gambar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D8E0),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari...",
                    hintStyle: GoogleFonts.poppins(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: Colors.black87),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // List Aktivitas Pinjaman
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                itemCount: _pinjamanData.length,
                itemBuilder: (context, index) {
                  return _buildAktivitasCard(_pinjamanData[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAktivitasCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Kolom teks Nama dan Tanggal
          Expanded(
            child: Column(
              children: [
                _buildInfoRow("Nama", data['nama']),
                const SizedBox(height: 5),
                _buildInfoRow("Tanggal", data['tanggal']),
              ],
            ),
          ),
          
          // Badge Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: data['color'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data['status'],
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          
          // Icon Arrow
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF02182F),
            ),
          ),
        ),
        Text(
          ":  $value",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF02182F),
          ),
        ),
      ],
    );
  }
}
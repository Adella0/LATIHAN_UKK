import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPeminjamanScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailPeminjamanScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Logika Deteksi Status
    final String status = (data['status_transaksi'] ?? '').toLowerCase();
    final bool isDitolak = status == "ditolak";
    
    // Logika Denda (Contoh: jika ada data denda dari database)
    final bool isTerlambat = data['denda'] != null && data['denda'] > 0;
    final String dendaAmount = data['denda'] != null ? "Rp${data['denda']}" : "-";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF02182F)),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        isDitolak ? "Detail riwayat" : "Detail riwayat",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF02182F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balancer agar teks tengah
                ],
              ),
              const SizedBox(height: 30),

              // Input Nama (Read Only)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Nama", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                  if (isTerlambat && !isDitolak)
                    Text("Terlambat 2 hari", // Harusnya dinamis dari data
                        style: GoogleFonts.poppins(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(data['users']?['nama'] ?? "Monica", style: GoogleFonts.poppins()),
              ),
              const SizedBox(height: 25),

              // Panel Tanggal
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDateItem("Pengambilan", "21/01/2026 | 08.30"),
                    _buildDateItem("Tenggat", "23/01/2026 | 08.30"),
                    _buildDateItem("Pengembalian", isDitolak ? "-" : "23/01/2026 | 08.30"),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // List Alat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Alat:", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text("Total alat (2)", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF02182F))),
                ],
              ),
              const SizedBox(height: 15),
              _buildAlatCard("Proyektor", "Elektronik", "(1) unit"),
              _buildAlatCard("Proyektor", "Elektronik", "(1) unit"),
              const SizedBox(height: 25),

              // --- BAGIAN DINAMIS SESUAI GAMBAR ---
              if (isDitolak) ...[
                // TAMPILAN GAMBAR 3 (Ditolak)
                Text("Alasan ditolak :", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.red)),
                const SizedBox(height: 5),
                Text(data['alasan_tolak'] ?? "Alat sedang diperbaiki", style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(height: 50),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB91C1C),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cancel_outlined, color: Colors.white),
                      const SizedBox(width: 10),
                      Text("Peminjaman alat ditolak", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ] else ...[
                // TAMPILAN GAMBAR 1 & 2 (Selesai/Denda)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      _buildDendaRow("Denda", isTerlambat ? "Terlambat" : "-"),
                      const Divider(height: 25),
                      _buildDendaRow("Alasan", isTerlambat ? "Terlambat mengembalikan alat" : "-"),
                      const Divider(height: 25),
                      _buildDendaRow("Total denda:", isTerlambat ? "Rp10.000" : "-"),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF02182F))),
        const SizedBox(height: 5),
        Text(value, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildAlatCard(String nama, String kategori, String jumlah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 50,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.videocam, color: Colors.black54), // Ganti dengan Image.network jika ada URL
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(kategori, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF02182F))),
              ],
            ),
          ),
          Text(jumlah, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDendaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
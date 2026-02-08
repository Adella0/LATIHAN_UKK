import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPeminjamanScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailPeminjamanScreen({super.key, required this.data});

  // --- FUNGSI FORMAT TANGGAL CUSTOM ---
  String formatTanggal(String? rawDate) {
    if (rawDate == null || rawDate == "-" || rawDate.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(rawDate);
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString();
      String hour = dt.hour.toString().padLeft(2, '0');
      String minute = dt.minute.toString().padLeft(2, '0');
      return "$day/$month/$year | $hour.$minute";
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = (data['status_transaksi'] ?? '').toLowerCase();
    final bool isDitolak = status == "ditolak";
    
    final dynamic dendaData = data['denda'];
    final bool isTerlambat = dendaData != null && 
        (dendaData is Map ? (dendaData['total_denda'] ?? 0) > 0 : false);

    List<dynamic> rawDetails = data['detail_peminjaman'] ?? [];
    Map<String, Map<String, dynamic>> groupedAlat = {};

    for (var detail in rawDetails) {
      final alat = detail['alat'];
      if (alat != null) {
        String namaAlat = alat['nama_alat'] ?? "Tanpa Nama";
        if (groupedAlat.containsKey(namaAlat)) {
          groupedAlat[namaAlat]!['jumlah_tampil'] += (detail['jumlah'] ?? 1);
        } else {
          groupedAlat[namaAlat] = {
            'nama': namaAlat,
            'kategori': (alat['kategori'] is Map) 
                ? (alat['kategori']['nama_kategori'] ?? 'Elektronik') 
                : 'Elektronik',
            'foto': alat['foto_url'],
            'jumlah_tampil': detail['jumlah'] ?? 1,
          };
        }
      }
    }

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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF02182F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Detail riwayat",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF02182F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 35),

              // Label Nama
              Text("Nama", 
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black)
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(data['users']?['nama'] ?? "-", 
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
              ),
              const SizedBox(height: 25),

              // Panel Tanggal (Mapping Nama Kolom DB Anda)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08), 
                      blurRadius: 15, 
                      offset: const Offset(0, 4)
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDateItem("Pengambilan", formatTanggal(data['pengambilan'])),
                    _buildDateItem("Tenggat", formatTanggal(data['tenggat'])),
                    _buildDateItem("Pengembalian", isDitolak ? "-" : formatTanggal(data['pengembalian'])),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Label Alat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Alat:", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text("Total alat (${groupedAlat.length})", 
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF02182F))),
                ],
              ),
              const SizedBox(height: 15),
              
              if (groupedAlat.isEmpty)
                Center(child: Text("Data alat tidak ditemukan", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)))
              else
                ...groupedAlat.values.map((a) => _buildAlatCard(
                  a['nama'], 
                  a['kategori'], 
                  "(${a['jumlah_tampil']}) unit",
                  a['foto']
                )),

              const SizedBox(height: 20),

              // Panel Denda / Alasan Ditolak
              if (isDitolak) ...[
                Text("Alasan ditolak :", 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFFC01C1C), fontSize: 13)
                ),
                const SizedBox(height: 6),
                Text(data['alasan_penolakan'] ?? "Alat sedang diperbaiki", 
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08), 
                        blurRadius: 15, 
                        offset: const Offset(0, 4)
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDendaRow("Denda", isTerlambat ? "Terlambat" : "-"),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Color(0xFFF1F5F9)),
                      ),
                      _buildDendaRow("Alasan", isTerlambat ? "Terlambat mengembalikan alat" : "-"),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Color(0xFFF1F5F9)),
                      ),
                      _buildDendaRow("Total denda:", isTerlambat ? "Rp${dendaData['total_denda']}" : "-"),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
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
        const SizedBox(height: 8),
        Text(value, 
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w500)
        ),
      ],
    );
  }

  Widget _buildAlatCard(String nama, String kategori, String jumlah, String? imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), 
            blurRadius: 15, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2_outlined, color: Colors.grey))
                  : const Icon(Icons.inventory_2_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black)),
                Text(kategori, style: GoogleFonts.poppins(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          Text(jumlah, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF02182F))),
        ],
      ),
    );
  }

  Widget _buildDendaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }
}
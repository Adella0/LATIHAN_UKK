import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../persetujuan/detail_peminjaman.dart';

class RiwayatPersetujuan extends StatefulWidget {
  const RiwayatPersetujuan({super.key});

  @override
  State<RiwayatPersetujuan> createState() => _RiwayatPersetujuanState();
}

class _RiwayatPersetujuanState extends State<RiwayatPersetujuan> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _riwayatData = [];

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    try {
      // Ambil data yang sudah diproses (status bukan pending)
    // Contoh query di halaman Riwayat
final data = await supabase
    .from('peminjaman')
    .select('''
      *, 
      peminjam:users!peminjam_id(nama),
      detail_peminjaman!detail_peminjaman_id_pinjam_fkey(
        jumlah,
        alat!detail_peminjaman_id_alat_fkey(nama_alat)
      )
    ''')
    .neq('status_transaksi', 'pending'); // Atau filter riwayat Anda

      setState(() {
        _riwayatData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error Fetch Riwayat: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      return DateFormat('dd/MM/yyyy | HH.mm').format(DateTime.parse(dateStr).toLocal());
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_riwayatData.isEmpty) {
      return Center(child: Text("Belum ada riwayat pengajuan", style: GoogleFonts.poppins(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _riwayatData.length,
      itemBuilder: (context, index) {
        final item = _riwayatData[index];
        final String status = item['status_transaksi'] ?? 'aktif';
        final String namaPeminjam = item['peminjam']?['nama'] ?? "User";
        
        // Menghitung jumlah alat dengan aman
        final int jmlAlat = (item['detail_peminjaman'] as List?)?.length ?? 0;

        // Penentuan warna status sesuai gambar
        Color statusColor = const Color(0xFF28C76F); // Hijau (Disetujui)
        String statusLabel = "Disetujui";

        if (status == 'ditolak') {
          statusColor = const Color(0xFFEA5455); // Merah (Ditolak)
          statusLabel = "Ditolak";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              // Header Card: Profil, Nama, Status
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFF1A1A1A),
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(namaPeminjam, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                          child: Text("Peminjam", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade700)),
                        ),
                      ],
                    ),
                  ),
                  // Badge Status sesuai Gambar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.black12),
              const SizedBox(height: 10),

              // Baris Info: Pengambilan, Tenggat, Alat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCol("Pengambilan", _formatDate(item['pengambilan'])),
                  _buildInfoCol("Tenggat", _formatDate(item['tenggat'])),
                  _buildInfoCol("Alat", jmlAlat.toString()),
                ],
              ),
              const SizedBox(height: 15),

              // Link Lihat Detail
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                                    onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPinjamanScreen(idPinjam: item['id_pinjam']),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Lihat detail", style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                      const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCol(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF02182F))),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87), textAlign: TextAlign.center),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DetailPinjamanScreen extends StatefulWidget {
  final int idPinjam;
  const DetailPinjamanScreen({super.key, required this.idPinjam});

  @override
  State<DetailPinjamanScreen> createState() => _DetailPinjamanScreenState();
}

class _DetailPinjamanScreenState extends State<DetailPinjamanScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _dataPinjam;
  List<dynamic> _listAlat = [];

  @override
  void initState() {
    super.initState();
    _fetchDetailLengkap();
  }

  // Taktik 2 Tahap: Agar tidak bentrok relasi PGRST201 dan data pasti aman
  Future<void> _fetchDetailLengkap() async {
    try {
      setState(() => _isLoading = true);

      // 1. Ambil data utama & User
      final resPinjam = await supabase
          .from('peminjaman')
          .select('*, peminjam:users!peminjam_id(nama)')
          .eq('id_pinjam', widget.idPinjam)
          .maybeSingle();

      if (resPinjam != null) {
        // 2. Ambil detail alat (Gunakan relasi spesifik agar tidak PGRST201)
        final resAlat = await supabase
            .from('detail_peminjaman')
            .select('jumlah, alat:alat!detail_peminjaman_id_alat_fkey(nama_alat, foto_url, kategori:kategori_id(nama_kategori))')
            .eq('id_pinjam', widget.idPinjam);

        setState(() {
          _dataPinjam = resPinjam;
          _listAlat = resAlat;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error Fatal Peminjam: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? date) {
    if (date == null || date == "null" || date.isEmpty) return "-";
    try {
      return DateFormat('dd/MM/yyyy | HH.mm').format(DateTime.parse(date).toLocal());
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF02182F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Detail", style: GoogleFonts.poppins(color: const Color(0xFF02182F), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF02182F)))
          : _dataPinjam == null 
              ? const Center(child: Text("Data tidak ditemukan"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nama", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildStaticField(_dataPinjam?['peminjam']?['nama'] ?? "Nama tidak ditemukan"),
                      
                      const SizedBox(height: 20),
                      
                      // Info Box Tanggal (Sesuai Gambar Monica)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildDateItem("Pengambilan", _formatDate(_dataPinjam?['pengambilan'])),
                            _buildDateItem("Tenggat", _formatDate(_dataPinjam?['tenggat'])),
                            _buildDateItem("Pengembalian", _formatDate(_dataPinjam?['pengembalian'])),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Alat:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Total alat (${_listAlat.length})", style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey)),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // List Alat
                      ..._listAlat.map((item) => _buildAlatCard(item)).toList(),

                      // Tombol Ajukan Pengembalian (Hanya jika Status Aktif)
                      if (_dataPinjam?['status_transaksi'] == 'aktif') ...[
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () { /* Fungsi pengembalian Anda */ },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF02182F),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("Ajukan pengembalian", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
    );
  }

  Widget _buildStaticField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(value, style: GoogleFonts.poppins(color: Colors.black87)),
    );
  }

  Widget _buildDateItem(String label, String date) {
    List<String> parts = date.split('|');
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(color: const Color(0xFF02182F), fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(parts[0].trim(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500)),
        if (parts.length > 1)
          Text(parts[1].trim(), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAlatCard(dynamic item) {
    final alat = item['alat'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              alat?['foto_url'] ?? 'https://via.placeholder.com/50',
              width: 50, height: 50, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2, size: 30, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alat?['nama_alat'] ?? "Alat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                Text(alat?['kategori']?['nama_kategori'] ?? "Elektronik", style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
          ),
          Text("(${item['jumlah']}) unit", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
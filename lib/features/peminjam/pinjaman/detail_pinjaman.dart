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
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      // 1. Ambil data utama peminjaman
      final resPinjam = await supabase
          .from('peminjaman')
          .select('*, users!peminjam_id(nama)')
          .eq('id_pinjam', widget.idPinjam)
          .single();

      // 2. Ambil daftar alat dari tabel detail_peminjaman
      final resAlat = await supabase
          .from('detail_peminjaman')
          .select('*, alat(*)')
          .eq('id_pinjam', widget.idPinjam);

      setState(() {
        _dataPinjam = resPinjam;
        _listAlat = resAlat;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? date) {
    if (date == null || date == "null") return "-";
    return DateFormat('dd/MM/yyyy | HH.mm').format(DateTime.parse(date).toLocal());
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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nama", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _dataPinjam?['users']['nama'],
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Info Box Tanggal
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateItem("Pengambilan", _formatDate(_dataPinjam?['pengambilan'])),
                        _buildDateItem("Tenggat", _formatDate(_dataPinjam?['tenggat'])),
                        _buildDateItem("Pengembalian", _formatDate(_dataPinjam?['pengembalian'].toString())),
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _listAlat.length,
                    itemBuilder: (context, index) {
                      final alat = _listAlat[index]['alat'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                alat['foto_url'] ?? 'https://via.placeholder.com/50',
                                width: 50, height: 50, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(alat['nama_alat'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                  Text("Elektronik", style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey)),
                                ],
                              ),
                            ),
                            Text("(${_listAlat[index]['jumlah']}) unit", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    },
                  ),

                  // Tampilkan Alasan Penolakan jika ada
                  if (_dataPinjam?['status_transaksi'] == 'ditolak') ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Alasan Penolakan:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                          Text(_dataPinjam?['alasan_penolakan'] ?? "-", style: GoogleFonts.poppins(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                  // Tombol Aksi (Hanya muncul jika sudah disetujui tapi belum dikembalikan)
                  if (_dataPinjam?['status_transaksi'] == 'aktif')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () { /* Fungsi Ajukan Pengembalian */ },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF02182F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Ajukan pengembalian", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDateItem(String label, String date) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF02182F), borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(date.split('|')[0], style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500)),
        Text(date.contains('|') ? date.split('|')[1] : "", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
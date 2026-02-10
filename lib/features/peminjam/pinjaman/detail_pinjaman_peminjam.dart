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
  Map<String, dynamic>? _dataDenda; // Tambahan untuk simpan data denda

  @override
  void initState() {
    super.initState();
    _fetchDetailLengkap();
  }

  Future<void> _fetchDetailLengkap() async {
  try {
    setState(() => _isLoading = true);

    // Tambahkan .select() tanpa cache dengan cara memanggilnya ulang
    final resPinjam = await supabase
        .from('peminjaman')
        .select('*, peminjam:users!peminjam_id(nama)')
        .eq('id_pinjam', widget.idPinjam)
        .maybeSingle();

    debugPrint("DATA DARI DB: ${resPinjam?['Pengembalian']}"); // CEK DI CONSOLE LOG

    if (resPinjam != null) {
      final resAlat = await supabase
          .from('detail_peminjaman')
          .select('jumlah, alat:alat!detail_peminjaman_id_alat_fkey(nama_alat, foto_url, kategori:kategori_id(nama_kategori))')
          .eq('id_pinjam', widget.idPinjam);

      // Ambil denda jika ada
      final resDenda = await supabase
          .from('denda')
          .select()
          .eq('id_kembali', widget.idPinjam)
          .maybeSingle();

      setState(() {
        _dataPinjam = resPinjam;
        _listAlat = resAlat;
        _dataDenda = resDenda;
        _isLoading = false;
      });
    }
  } catch (e) {
    debugPrint("Error Fetch: $e");
    setState(() => _isLoading = false);
  }
}

  Future<void> _ajukanPengembalian() async {
    try {
      setState(() => _isLoading = true);

      // SAAT MENGAJUKAN: Jangan isi 'Pengembalian' dulu, 
      // biarkan Petugas yang mengisi tanggal pastinya nanti.
      await supabase.from('peminjaman').update({
        'status_transaksi': 'dikembalikan',
      }).eq('id_pinjam', widget.idPinjam);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil diajukan!"), backgroundColor: Colors.orange),
        );
        _fetchDetailLengkap(); // Refresh data tanpa pindah halaman
      }
    } catch (e) {
      debugPrint("Error Update: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? date) {
  // Debug untuk melihat apa yang masuk ke fungsi format
  debugPrint("Formatting date: $date"); 

  if (date == null || date == "null" || date.trim().isEmpty) return "-";
  
  try {
    // 1. Parse string ke DateTime
    DateTime parsedDate = DateTime.parse(date);
    
    // 2. Paksa ke Local Time (WIB)
    DateTime localDate = parsedDate.toLocal();
    
    // 3. Kembalikan string hasil format
    return DateFormat('dd/MM/yyyy | HH.mm').format(localDate);
  } catch (e) {
    debugPrint("Gagal format tanggal: $e");
    return "Format Error";
  }
}

  @override
  Widget build(BuildContext context) {
    final status = _dataPinjam?['status_transaksi'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF02182F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Detail Pinjaman", style: GoogleFonts.poppins(color: const Color(0xFF02182F), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF02182F)))
          : RefreshIndicator(
              onRefresh: _fetchDetailLengkap,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama Peminjam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildStaticField(_dataPinjam?['peminjam']?['nama'] ?? "-"),
                    
                    const SizedBox(height: 20),
                    
                    // Box Tanggal (Pastikan 'Pengembalian' P Kapital)
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
                          _buildDateItem("Pinjam", _formatDate(_dataPinjam?['pengambilan'])),
                          _buildDateItem("Tenggat", _formatDate(_dataPinjam?['tenggat'])),
                          _buildDateItem("Kembali", _formatDate(_dataPinjam?['Pengembalian']?.toString())),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    Text("Daftar Alat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    ..._listAlat.map((item) => _buildAlatCard(item)).toList(),

                    // TAMPILAN DENDA (Hanya muncul jika ada denda)
                    if (_dataDenda != null) ...[
                      const SizedBox(height: 20),
                      Text("Detail Denda", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Terlambat ${_dataDenda!['jumlah_terlambat']} Hari", style: GoogleFonts.poppins(fontSize: 13)),
                            Text("Rp${NumberFormat('#,###').format(_dataDenda!['total_denda'])}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Logika Tombol
                    if (status == 'aktif') 
                      _buildActionButton("Ajukan Pengembalian", const Color(0xFF02182F), _showConfirmDialog)
                    else if (status == 'dikembalikan') 
                      _buildStatusNotice("Menunggu Konfirmasi Petugas...", Colors.orange)
                    else if (status == 'selesai') 
                      _buildStatusNotice("Pinjaman Selesai (Barang Diterima)", const Color(0xFF535453))
                    else if (status == 'ditolak')
                      _buildStatusNotice("Pengajuan Ditolak", Colors.red),
                  ],
                ),
              ),
            ),
    );
  }

  // --- Widget helper tetap sama dengan perbaikan filter null ---
  Widget _buildStaticField(String value) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Text(value, style: GoogleFonts.poppins()),
    );
  }

  Widget _buildDateItem(String label, String date) {
    List<String> parts = date.split('|');
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(color: const Color(0xFF02182F), fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(parts[0].trim(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500)),
        if (parts.length > 1) Text(parts[1].trim(), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAlatCard(dynamic item) {
    final alat = item['alat'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              alat?['foto_url'] ?? 'https://via.placeholder.com/50',
              width: 50, height: 50, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(alat?['nama_alat'] ?? "Alat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            Text(alat?['kategori']?['nama_kategori'] ?? "-", style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey)),
          ])),
          Text("${item['jumlah']} Unit", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(label, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))));
  }

  Widget _buildStatusNotice(String message, Color color) {
    return Center(child: Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color)), child: Center(child: Text(message, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold)))));
  }

  void _showConfirmDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Konfirmasi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      content: const Text("Ajukan pengembalian alat sekarang?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(onPressed: () { Navigator.pop(context); _ajukanPengembalian(); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF02182F)), child: const Text("Ya, Ajukan", style: TextStyle(color: Colors.white))),
      ],
    ));
  }
}
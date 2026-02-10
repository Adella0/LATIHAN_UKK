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
  Map<String, dynamic>? dataPinjam;
  List<dynamic> listAlat = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetailSangatAman();
  }

  Future<void> _fetchDetailSangatAman() async {
    try {
      setState(() => isLoading = true);

      // TAHAP 1: Ambil data peminjaman dan nama user saja
      final resUtama = await supabase
          .from('peminjaman')
          .select('*, users!peminjam_id(nama)')
          .eq('id_pinjam', widget.idPinjam)
          .maybeSingle();

      if (resUtama != null) {
        // TAHAP 2: Ambil detail alat secara terpisah untuk menghindari error PGRST201
        // Kita gunakan petunjuk dari error: 'alat!detail_peminjaman_id_alat_fkey'
        final resAlat = await supabase
            .from('detail_peminjaman')
            .select('jumlah, alat!detail_peminjaman_id_alat_fkey(nama_alat, foto_url)')
            .eq('id_pinjam', widget.idPinjam);

        setState(() {
          dataPinjam = resUtama;
          listAlat = resAlat;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error Fetch: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF02182F))));
    
    // Jika data tetap tidak ada, kita tampilkan pesan agar tidak bingung
    if (dataPinjam == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detail")),
        body: const Center(child: Text("Data ID ini tidak ditemukan di database")),
      );
    }

    final String namaPeminjam = dataPinjam?['users']?['nama'] ?? "Nama tidak ditemukan";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Detail", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(namaPeminjam, style: GoogleFonts.poppins()),
            ),

            const SizedBox(height: 25),
            
            // Info Card Waktu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoWaktu("Pengambilan", dataPinjam?['pengambilan']),
                  _infoWaktu("Tenggat", dataPinjam?['tenggat']),
                  _infoWaktu("Kembali", dataPinjam?['pengembalian']),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Text("Alat:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            // Tampilkan list alat jika ada
            listAlat.isEmpty 
              ? const Text("Tidak ada alat terdaftar") 
              : Column(
                  children: listAlat.map((item) => _itemAlat(item)).toList(),
                ),
          ],
        ),
      ),
    );
  }

  Widget _infoWaktu(String label, String? tgl) {
    String formatted = "-";
    if (tgl != null) {
      formatted = DateFormat('dd/MM/yyyy').format(DateTime.parse(tgl).toLocal());
    }
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF02182F))),
        const SizedBox(height: 4),
        Text(formatted, style: GoogleFonts.poppins(fontSize: 10)),
      ],
    );
  }

  Widget _itemAlat(dynamic item) {
    final alat = item['alat'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              alat?['foto_url'] ?? 'https://via.placeholder.com/50',
              width: 50, height: 50, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(alat?['nama_alat'] ?? "Alat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
          Text("(${item['jumlah']}) unit", style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }
}
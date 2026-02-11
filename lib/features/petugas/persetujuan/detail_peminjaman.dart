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

  // Theme Colors
  final Color _primaryColor = const Color(0xFF02182F);
  final Color _accentColor = const Color(0xFF3498DB);
  final Color _bgColor = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _fetchDetailSangatAman();
  }

  Future<void> _fetchDetailSangatAman() async {
    try {
      setState(() => isLoading = true);
      final resUtama = await supabase
          .from('peminjaman')
          .select('*, users!peminjam_id(nama)')
          .eq('id_pinjam', widget.idPinjam)
          .maybeSingle();

      if (resUtama != null) {
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
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
      );
    }

    if (dataPinjam == null) {
      return Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.white),
        body: Center(child: Text("Data tidak ditemukan", style: GoogleFonts.poppins())),
      );
    }

    final String namaPeminjam = dataPinjam?['users']?['nama'] ?? "User";
    final String status = dataPinjam?['status'] ?? "Diproses";

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text("Detail Transaksi", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Section dengan Background Putih
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFF1F4F8),
                    child: Icon(Icons.person_outline, size: 40, color: Color(0xFF02182F)),
                  ),
                  const SizedBox(height: 15),
                  Text(namaPeminjam,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      )),
                  const SizedBox(height: 5),
                  _buildStatusBadge(status),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline/Time Info Section
                  Text("Informasi Waktu", 
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  _buildTimeCard(),

                  const SizedBox(height: 35),
                  
                  // Daftar Alat Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Daftar Alat", 
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${listAlat.length} Unit", 
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  listAlat.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: listAlat.map((item) => _itemAlat(item)).toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _accentColor,
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _infoWaktu("PINJAM", dataPinjam?['pengambilan'], Icons.calendar_today_rounded),
          Container(height: 30, width: 1, color: Colors.grey.shade200),
          _infoWaktu("TENGGAT", dataPinjam?['tenggat'], Icons.timer_outlined),
          Container(height: 30, width: 1, color: Colors.grey.shade200),
          _infoWaktu("KEMBALI", dataPinjam?['pengembalian'], Icons.check_circle_outline_rounded),
        ],
      ),
    );
  }

  Widget _infoWaktu(String label, String? tgl, IconData icon) {
    String formatted = "-";
    if (tgl != null) {
      formatted = DateFormat('dd MMM').format(DateTime.parse(tgl).toLocal());
    }
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(formatted, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: _primaryColor)),
      ],
    );
  }

  Widget _itemAlat(dynamic item) {
    final alat = item['alat'];
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              alat?['foto_url'] ?? 'https://via.placeholder.com/60',
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60, height: 60, color: _bgColor,
                child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alat?['nama_alat'] ?? "Alat", 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Item terpilih", 
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("${item['jumlah']} Unit", 
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text("Tidak ada alat terdaftar", 
        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
    );
  }
}
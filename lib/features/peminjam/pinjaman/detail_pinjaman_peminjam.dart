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
  Map<String, dynamic>? _dataDenda;

  final Color _primaryDark = const Color(0xFF02182F);
  final Color _accentBlue = const Color(0xFF3A7BD5);
  final Color _bgGrey = const Color(0xFFF8FAFC);
  final Color _mediumGrey = const Color(0xFF8F8E90);

  @override
  void initState() {
    super.initState();
    _fetchDetailLengkap();
  }

  // --- LOGIC FETCH (TETAP SAMA) ---
  Future<void> _fetchDetailLengkap() async {
    try {
      setState(() => _isLoading = true);
      final resPinjam = await supabase
          .from('peminjaman')
          .select('*, peminjam:users!peminjam_id(nama)')
          .eq('id_pinjam', widget.idPinjam)
          .maybeSingle();

      if (resPinjam != null) {
        final resAlat = await supabase
            .from('detail_peminjaman')
            .select('jumlah, alat:alat!detail_peminjaman_id_alat_fkey(nama_alat, foto_url, kategori:kategori_id(nama_kategori))')
            .eq('id_pinjam', widget.idPinjam);

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
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _ajukanPengembalian() async {
    try {
      setState(() => _isLoading = true);
      await supabase.from('peminjaman').update({'status_transaksi': 'dikembalikan'}).eq('id_pinjam', widget.idPinjam);
      _fetchDetailLengkap();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? date) => (date == null || date == "null") ? "-" : DateFormat('dd MMMM yyyy').format(DateTime.parse(date).toLocal());
  String _formatTime(String? date) => (date == null || date == "null") ? "" : DateFormat('HH:mm WIB').format(DateTime.parse(date).toLocal());

  @override
  Widget build(BuildContext context) {
    final status = _dataPinjam?['status_transaksi'] ?? '';

    return Scaffold(
      backgroundColor: _bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _primaryDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Detail Transaksi", style: GoogleFonts.poppins(color: _primaryDark, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryDark))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(status),
                  const SizedBox(height: 30),
                  _buildSectionHeader("Timeline Aktivitas"),
                  _buildModernTimeline(status),
                  const SizedBox(height: 30),
                  _buildSectionHeader("Alat yang Dipinjam"),
                  ..._listAlat.map((item) => _buildAlatTile(item)).toList(),
                  if (_dataDenda != null) _buildDendaCard(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
      bottomSheet: _buildBottomAction(status),
    );
  }

  // --- MODERN COMPONENTS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: _primaryDark)),
    );
  }

  Widget _buildSummaryCard(String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _primaryDark.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ID PINJAM #ID-${widget.idPinjam.toString().padLeft(4, '0')}", 
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 15),
          Text(_dataPinjam?['peminjam']?['nama'] ?? "-", 
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Peminjam Terdaftar", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildModernTimeline(String status) {
    bool isReturned = _dataPinjam?['Pengembalian'] != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          _buildTimelineStep("Waktu Peminjaman", _dataPinjam?['pengambilan'], Icons.calendar_today, Colors.blue, true),
          _buildTimelineStep("Tenggat Pengembalian", _dataPinjam?['tenggat'], Icons.alarm, Colors.orange, isReturned),
          if (isReturned)
            _buildTimelineStep("Realisasi Pengembalian", _dataPinjam?['Pengembalian'], Icons.check_circle, Colors.green, false),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String? date, IconData icon, Color color, bool showLine) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: color),
              ),
              if (showLine) Expanded(child: Container(width: 2, color: _bgGrey)),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 11, color: _mediumGrey)),
                Text(_formatDate(date), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: _primaryDark)),
                Text(_formatTime(date), style: GoogleFonts.poppins(fontSize: 11, color: _mediumGrey)),
                const SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAlatTile(dynamic item) {
    final alat = item['alat'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(alat?['foto_url'] ?? '', width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.image, color: _mediumGrey)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alat?['nama_alat'] ?? "Alat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(alat?['kategori']?['nama_kategori'] ?? "-", style: GoogleFonts.poppins(fontSize: 11, color: _mediumGrey)),
              ],
            ),
          ),
          Text("${item['jumlah']}x", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _accentBlue)),
        ],
      ),
    );
  }

  Widget _buildDendaCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.shade100)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Denda", style: GoogleFonts.poppins(fontSize: 12, color: Colors.red.shade900)),
              Text("Terlambat ${_dataDenda!['jumlah_terlambat']} Hari", style: GoogleFonts.poppins(fontSize: 11, color: Colors.red.shade700)),
            ],
          ),
          Text("Rp${NumberFormat('#,###').format(_dataDenda!['total_denda'])}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildBottomAction(String status) {
    if (status != 'aktif' && status != 'dikembalikan') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(25),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: status == 'aktif' ? _showConfirmDialog : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: status == 'aktif' ? _primaryDark : _mediumGrey.withOpacity(0.2),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            status == 'aktif' ? "AJUKAN PENGEMBALIAN" : "MENUNGGU KONFIRMASI...",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: status == 'aktif' ? Colors.white : _mediumGrey),
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("Kembalikan Alat?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      content: Text("Pastikan semua item dalam kondisi baik.", style: GoogleFonts.poppins(fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: _mediumGrey))),
        ElevatedButton(
          onPressed: () { Navigator.pop(context); _ajukanPengembalian(); },
          style: ElevatedButton.styleFrom(backgroundColor: _primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text("Ya, Kembalikan", style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
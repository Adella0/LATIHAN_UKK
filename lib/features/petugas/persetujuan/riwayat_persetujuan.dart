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

  final Color _primaryDark = const Color(0xFF02182F);
  // Warna background dirubah agar kartu putih terlihat kontras
  final Color _screenBg = const Color(0xFFF1F4F8); 

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    try {
      setState(() => _isLoading = true);
      final user = supabase.auth.currentUser;
      if (user == null) return;

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
          .eq('petugas_id', user.id)
          .neq('status_transaksi', 'pending')
          .order('id_pinjam', ascending: false);

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
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr).toLocal());
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg, // Pastikan background layar gelap sedikit
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryDark))
          : _riwayatData.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: _primaryDark,
                  onRefresh: _fetchRiwayat,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _riwayatData.length,
                    itemBuilder: (context, index) {
                      final item = _riwayatData[index];
                      return _buildHistoryCard(item);
                    },
                  ),
                ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    final String status = item['status_transaksi'] ?? 'aktif';
    final String namaPeminjam = item['peminjam']?['nama'] ?? "User";
    final int jmlAlat = (item['detail_peminjaman'] as List?)?.length ?? 0;

    // Config Warna Status
    Color statusBg = const Color(0xFFE8F9EE);
    Color statusText = const Color(0xFF28C76F);
    String statusLabel = "Disetujui";

    if (status == 'ditolak') {
      statusBg = const Color(0xFFFFEBEB);
      statusText = const Color(0xFFEA5455);
      statusLabel = "Ditolak";
    } else if (status == 'selesai') {
      statusBg = const Color(0xFFF1F4F8);
      statusText = const Color(0xFF454545);
      statusLabel = "Selesai";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // SHADOW diperkuat agar tidak menyatu dengan background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPinjamanScreen(idPinjam: item['id_pinjam']),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // PROFIL BULAT
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _primaryDark.withOpacity(0.08),
                        shape: BoxShape.circle, // Diubah menjadi bulat
                      ),
                      child: Center(
                        child: Text(
                          namaPeminjam[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, 
                            color: _primaryDark,
                            fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(namaPeminjam,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 15, 
                                  color: _primaryDark)),
                          Text("ID Transaksi: #${item['id_pinjam']}",
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.poppins(
                            color: statusText,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, thickness: 0.6, color: Color(0xFFF1F1F1)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(Icons.calendar_today_outlined, "Pinjam", _formatDate(item['pengambilan'])),
                    _buildInfoItem(Icons.timer_outlined, "Tenggat", _formatDate(item['tenggat'])),
                    _buildInfoItem(Icons.inventory_2_outlined, "Alat", "$jmlAlat Item"),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Lihat rincian", 
                      style: GoogleFonts.poppins(
                        fontSize: 11, 
                        fontWeight: FontWeight.w600, 
                        color: const Color(0xFF3498DB))),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF3498DB)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, 
          style: GoogleFonts.poppins(
            fontSize: 11, 
            fontWeight: FontWeight.w600, 
            color: _primaryDark)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Belum ada riwayat", style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}